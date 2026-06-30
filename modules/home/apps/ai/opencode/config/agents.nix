{
  config,
  ...
}:

let
  agents = "file:./agents";
  model = config.apps.ai.model;
in

{
  agent = {

    minerva = {
      mode = "primary";
      inherit model;
      prompt = "{${agents}/minerva.md}";
      reasoning_weight = "MAX";
    };

    flavius = {
      mode = "subagent";
      inherit model;
      prompt = "{${agents}/flavius.md}";
      reasoning_weight = "LOW";
    };

    gaius = {
      mode = "subagent";
      inherit model;
      prompt = "{${agents}/gaius.md}";
      reasoning_weight = "LOW";
    };

    vestal = {
      mode = "subagent";
      inherit model;
      prompt = "{${agents}/vestal.md}";
      reasoning_weight = "LOW";
    };

    thermae = {
      mode = "subagent";
      inherit model;
      prompt = "{${agents}/thermae.md}";
      reasoning_weight = "MEDIUM";
    };

    naturalis = {
      mode = "subagent";
      inherit model;
      prompt = "{${agents}/naturalis.md}";
      reasoning_weight = "MEDIUM";
    };

    pytheas = {
      mode = "subagent";
      inherit model;
      prompt = "{${agents}/pytheas.md}";
      reasoning_weight = "HIGH";
    };

  };
}
