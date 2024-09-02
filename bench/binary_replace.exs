small = "Lorem ipsum dolor"

medium = """
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce sed felis convallis, fermentum diam a, finibus augue. Suspendisse potenti. Cras eu ante lectus. Morbi a mauris nec tortor tempor accumsan eu vel eros. Duis venenatis vestibulum risus, eu venenatis purus rutrum sit amet. Etiam pharetra tincidunt neque. Sed finibus at enim at lobortis. Vestibulum sed dapibus elit. Fusce sagittis erat ultrices leo ornare ultricies. Nunc dignissim malesuada ipsum, eget placerat lectus accumsan vitae.

Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Quisque ultricies at massa in sollicitudin. Fusce sapien dui, lacinia non accumsan eget, lacinia sed purus. Morbi et ligula quis diam hendrerit sollicitudin. Sed massa tortor, facilisis sit amet luctus vitae, molestie vel turpis. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Donec quam turpis, fermentum non justo in, faucibus varius ipsum. Pellentesque dictum eros ultrices neque finibus lacinia. Quisque consectetur risus quis felis laoreet rhoncus.

Curabitur sodales quam ac mauris imperdiet, eu commodo dolor ornare. In nec molestie tortor, sed commodo lectus. Morbi at tempor tellus. Duis quis porttitor nibh. Nunc accumsan pulvinar lacus ac gravida. In ac erat ornare, blandit ipsum sed, consequat turpis. Nulla eu eleifend arcu. Pellentesque ante ex, sollicitudin at vulputate sit amet, fermentum sed nibh. Nullam consectetur tellus fringilla ex venenatis convallis. Interdum et malesuada fames ac ante ipsum primis in faucibus.
"""

large = String.duplicate(medium, 50)

simple_list = [" ", "\n"]
simple_pattern = :binary.compile_pattern(simple_list)

# this is the list that String.split/1 uses
complex_list = [
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
]

complex_pattern = :binary.compile_pattern(complex_list)

Benchee.run(
  %{
    "replace simple list" => fn string ->
      :binary.replace(string, simple_list, "-", [:global])
    end,
    "replace simple pattern" => fn string ->
      :binary.replace(string, simple_pattern, "-", [:global])
    end,
    "replace complex list" => fn string ->
      :binary.replace(string, complex_list, "-", [:global])
    end,
    "replace complex pattern" => fn string ->
      :binary.replace(string, complex_pattern, "-", [:global])
    end
  },
  inputs: [
    {"small", small},
    {"medium", medium},
    {"large", large}
  ],
  print: [fast_warning: false]
)
