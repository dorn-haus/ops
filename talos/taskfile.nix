{pkgs, ...}: let
  inherit (pkgs.lib) getExe getExe';

  bash = getExe pkgs.bash;
  grep = getExe' pkgs.gnugrep "grep";
  helmfile = getExe pkgs.helmfile;
  jq = getExe pkgs.jq;
  kubectl = getExe' pkgs.kubectl "kubectl";
  ping = getExe' pkgs.iputils "ping";
  rm = getExe' pkgs.coreutils "rm";
  sleep = getExe' pkgs.coreutils "sleep";
  talhelper = getExe' pkgs.talhelper "talhelper";
  talosctl = getExe pkgs.talosctl;
  test = getExe' pkgs.coreutils "test";
  xargs = getExe' pkgs.findutils "xargs";
  yq = getExe pkgs.yq;

  state = "$DEVENV_STATE/talos";
  writeYAML = (pkgs.formats.yaml {}).generate;
in
  writeYAML "taskfile.yaml" {
    version = 3;

    tasks = {
      bootstrap = {
        desc = "Bootstrap Talos cluster";
        cmds = [
          # TODO: gensecret
          {task = "genconfig";}
          {task = "apply-insecure";}
          {task = "install-k8s";}
          {task = "fetch-kubeconfig";}
          {task = "install-cilium";}
          "${talosctl} health --server=false"
        ];
      };

      genconfig = {
        desc = "Bootstrap Talos: #1 - generate configs";
        cmd = ''
          ${rm} -rf ${state}
          ${talhelper} genconfig --config-file="$TALCONFIG" --secret-file="$TALSECRET" --out-dir="${state}"
        '';
      };

      apply-insecure = {
        desc = "Bootstrap Talos: #2 - apply initial config";
        cmd = {
          task = "apply";
          vars = {extra_flags = "--insecure";};
        };
      };

      install-k8s = {
        desc = "Bootstrap Talos: #3 - bootstrap k8s cluster";
        cmd = ''
          echo "Installing Talos... this might take a while and print errors"
          until ${talhelper} gencommand bootstrap --config-file="$TALCONFIG" |
            ${bash}
          do ${sleep} 2
          done
        '';
      };

      fetch-kubeconfig = {
        desc = "Fetch Talos Kubernetes kubeconfig file";
        cmd = ''
          until ${talhelper} gencommand kubeconfig --config-file="$TALCONFIG" --out-dir=${state} \
            --extra-flags="--merge=false --force $KUBECONFIG" |
            ${bash}
          do ${sleep} 2
          done
        '';
      };

      install-cilium = {
        desc = "Bootstrap Talos: #4 - install cilium";
        cmd = let
          helmfile-yaml = ./apps/helmfile.nix;
        in ''
          # Wait for nodes to report not ready.
          # CNI is disabled initially, hence the nodes are not expected to be in ready state.
          until ${kubectl} wait --for=condition=Ready=false nodes --all --timeout=160s
          do ${sleep} 2
          done

          ${helmfile} apply --file=${helmfile-yaml} --skip-diff-on-install --suppress-diff

          # Wait until all nodes report ready.
          until ${kubectl} wait --for=condition=Ready nodes --all --timeout=120s
          do ${sleep} 2
          done
        '';
        preconditions = [
          {
            sh = "${test} -f $KUBECONFIG";
            msg = "Missing kubeconfig, run `task talos:fetch-kubeconfig` to fetch it.";
          }
        ];
      };

      apply = {
        desc = "Apply Talos config to all nodes";
        cmd = ''
          ${talhelper} gencommand apply \
            --config-file="$TALCONFIG" --out-dir=${state} --extra-flags="{{.extra_flags}}" |
            ${bash}
        '';
      };

      diff = {
        desc = "Diff Talos config on all nodes";
        cmd = {
          task = "apply";
          vars = {extra_flags = "--dry-run";};
        };
      };

      dashboard = {
        desc = "Show Talos dashboard on the first node";
        cmd = ''
          node="$(${yq} < $TALOSCONFIG '.context as $c | .contexts[$c] | .nodes[0]' -r)"
          ${talosctl} dashboard --nodes="$node"
        '';
      };

      ping = {
        desc = "Ping Talos nodes matching the pattern in nodes=";
        cmd = ''
          ${yq} < $TALCONFIG '.nodes[] | select(.hostname | test("^.*{{.nodes}}.*$")) | .ipAddress' \
          | ${xargs} -i ${ping} -c 1 {} {{.CLI_ARGS}}
        '';
      };

      upgrade-talos = {
        desc = "Upgrade Talos on a node";
        requires.vars = ["node" "version"];
        preconditions = [
          {
            sh = "${talosctl} get machineconfig --nodes={{.node}}";
            msg = "Talos node not found.";
          }
        ];
        status = [
          ''
            ${talosctl} version --nodes={{.node}} --json |
            ${jq} -r .version.tag |
            ${grep} 'v{{.version}}
          ''
        ];
        cmd = ''
          ${talosctl} upgrade \
            --nodes={{.node}} \
            --image=ghcr.io/siderolabs/installer:v{{.version}} \
            --reboot-mode=powercycle \
            --preserve=true
        '';
      };

      upgrade-k8s = {
        desc = "Upgrade Kubernetes on a node";
        requires.vars = ["node" "version"];
        preconditions = [
          {
            sh = "${talosctl} get machineconfig --nodes={{.node}}";
            msg = "Talos node not found.";
          }
        ];
        status = [
          ''
            ${kubectl} get node -ojson |
            ${jq} -r '.items[] | select(.metadata.name == "{{.node}}").status.nodeInfo.kubeletVersion' |
            ${grep} 'v{{.version}}
          ''
        ];
        cmd = ''
          ${talosctl} kpgrade-k8s --nodes={{.node}} --to=v{{.version}}
        '';
      };

      reset = {
        desc = "Resets Talos nodes back to maintenance mode";
        prompt = "Are you sure? This will destroy your cluster and reset the nodes back to maintenance mode.";
        cmd = ''
          ${talhelper} gencommand reset \
            --config-file=$TALCONFIG \
            --extra-flags="--reboot --system-labels-to-wipe=STATE --system-labels-to-wipe=EPHEMERAL --graceful=false --wait=false" |
            ${bash}
        '';
      };
    };
  }
