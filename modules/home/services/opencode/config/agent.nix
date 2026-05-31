{
  model,
  agents,
  ...
}:

{
  minerva = {
    mode = "primary";
    model = "${model}";
    prompt = "{${agents}/minerva.md}";
    reasoning_weight = "MAX";
  };

  flavius = {
    mode = "subagent";
    model = "${model}";
    prompt = "{${agents}/flavius.md}";
    reasoning_weight = "LOW";
  };

  gaius = {
    mode = "subagent";
    model = "${model}";
    prompt = "{${agents}/gaius.md}";
    reasoning_weight = "LOW";
  };

  vestal = {
    mode = "subagent";
    model = "${model}";
    prompt = "{${agents}/vestal.md}";
    reasoning_weight = "LOW";
  };

  thermae = {
    mode = "subagent";
    model = "${model}";
    prompt = "{${agents}/thermae.md}";
    reasoning_weight = "MEDIUM";
  };

  naturalis = {
    mode = "subagent";
    model = "${model}";
    prompt = "{${agents}/naturalis.md}";
    reasoning_weight = "MEDIUM";
  };

  pytheas = {
    mode = "subagent";
    model = "${model}";
    prompt = "{${agents}/pytheas.md}";
    reasoning_weight = "HIGH";
  };
}
