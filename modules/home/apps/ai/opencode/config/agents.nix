{
  config,
  ...
}:

let
  agents = "file:./agents";
  main = config.apps.ai.modelMain;
  sub = config.apps.ai.modelSub;
in

{
  agent = {

    minerva = {
      mode = "primary";
      model = main;
      prompt = "{${agents}/minerva.md}";
      #reasoning_weight = "MAX";
    };

    flavius = {
      mode = "subagent";
      model = sub;
      prompt = "{${agents}/flavius.md}";
      reasoning_weight = "LOW";
    };

    gaius = {
      mode = "subagent";
      model = sub;
      prompt = "{${agents}/gaius.md}";
      reasoning_weight = "LOW";
    };

    vestal = {
      mode = "subagent";
      model = sub;
      prompt = "{${agents}/vestal.md}";
      reasoning_weight = "LOW";
    };

    thermae = {
      mode = "subagent";
      model = sub;
      prompt = "{${agents}/thermae.md}";
      reasoning_weight = "MEDIUM";
    };

    naturalis = {
      mode = "subagent";
      model = sub;
      prompt = "{${agents}/naturalis.md}";
      reasoning_weight = "MEDIUM";
    };

    pytheas = {
      mode = "subagent";
      model = sub;
      prompt = "{${agents}/pytheas.md}";
      reasoning_weight = "HIGH";
    };

  };
}
