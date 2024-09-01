string = """
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce sed felis convallis, fermentum diam a, finibus augue. Suspendisse potenti. Cras eu ante lectus. Morbi a mauris nec tortor tempor accumsan eu vel eros. Duis venenatis vestibulum risus, eu venenatis purus rutrum sit amet. Etiam pharetra tincidunt neque. Sed finibus at enim at lobortis. Vestibulum sed dapibus elit. Fusce sagittis erat ultrices leo ornare ultricies. Nunc dignissim malesuada ipsum, eget placerat lectus accumsan vitae.

Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Quisque ultricies at massa in sollicitudin. Fusce sapien dui, lacinia non accumsan eget, lacinia sed purus. Morbi et ligula quis diam hendrerit sollicitudin. Sed massa tortor, facilisis sit amet luctus vitae, molestie vel turpis. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Donec quam turpis, fermentum non justo in, faucibus varius ipsum. Pellentesque dictum eros ultrices neque finibus lacinia. Quisque consectetur risus quis felis laoreet rhoncus.

Curabitur sodales quam ac mauris imperdiet, eu commodo dolor ornare. In nec molestie tortor, sed commodo lectus. Morbi at tempor tellus. Duis quis porttitor nibh. Nunc accumsan pulvinar lacus ac gravida. In ac erat ornare, blandit ipsum sed, consequat turpis. Nulla eu eleifend arcu. Pellentesque ante ex, sollicitudin at vulputate sit amet, fermentum sed nibh. Nullam consectetur tellus fringilla ex venenatis convallis. Interdum et malesuada fames ac ante ipsum primis in faucibus.
"""

pattern = :binary.compile_pattern([" ", "\n"])

whitespace =
  :binary.compile_pattern([
    "　",
    " ",
    "
",
    "
",
    " ",
    " ",
    " ",
    " ",
    " ",
    " ",
    " ",
    " ",
    " ",
    " ",
    " ",
    <<194, 133>>,
    " ",
    "\t",
    "\n",
    "\v",
    "\f",
    "\r"
  ])

Benchee.run(
  %{
    "String.split/1" => fn string -> String.split(string) end,
    "String.split/2 (string)" => fn string -> String.split(string, " ") end,
    "String.split/2 (list)" => fn string -> String.split(string, [" ", "\n"]) end,
    "String.split/2 (pattern)" => fn string -> String.split(string, pattern) end,
    "String.split/2 (whitespace pattern)" => fn string -> String.split(string, whitespace) end
  },
  inputs: [
    {"lorem", string}
    # {"small", "lorem ipsum"}
    # {"empty", ""}
  ],
  print: [fast_warning: false]
)
