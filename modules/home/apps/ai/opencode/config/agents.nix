{
  config,
  ...
}:

let
  agents = "file:./agents";
  defaultModel = config.apps.ai.model;
in

{
  agent = {

    minerva = {
      mode = "primary";
      model = defaultModel;
      prompt = "{${agents}/minerva.md}";
      reasoning_weight = "MAX";
    };

    flavius = {
      mode = "subagent";
      model = defaultModel;
      prompt = "{${agents}/flavius.md}";
      reasoning_weight = "LOW";
    };

    gaius = {
      mode = "subagent";
      model = defaultModel;
      prompt = "{${agents}/gaius.md}";
      reasoning_weight = "LOW";
    };

    vestal = {
      mode = "subagent";
      model = defaultModel;
      prompt = "{${agents}/vestal.md}";
      reasoning_weight = "LOW";
    };

    thermae = {
      mode = "subagent";
      model = defaultModel;
      prompt = "{${agents}/thermae.md}";
      reasoning_weight = "MEDIUM";
    };

    naturalis = {
      mode = "subagent";
      model = defaultModel;
      prompt = "{${agents}/naturalis.md}";
      reasoning_weight = "MEDIUM";
    };

    pytheas = {
      mode = "subagent";
      model = defaultModel;
      prompt = "{${agents}/pytheas.md}";
      reasoning_weight = "HIGH";
    };

  };
}
