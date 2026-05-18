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
  };

  flavius = {
    mode = "subagent";
    model = "${model}";
    prompt = "{${agents}/flavius.md}";
  };

  gaius = {
    mode = "subagent";
    model = "${model}";
    prompt = "{${agents}/gaius.md}";
  };

  vestal = {
    mode = "subagent";
    model = "${model}";
    prompt = "{${agents}/vestal.md}";
  };

  thermae = {
    mode = "subagent";
    model = "${model}";
    prompt = "{${agents}/thermae.md}";
  };

  naturalis = {
    mode = "subagent";
    model = "${model}";
    prompt = "{${agents}/naturalis.md}";
  };

  pytheas = {
    mode = "subagent";
    model = "${model}";
    prompt = "${agents}/pytheas.md";
  };
}
