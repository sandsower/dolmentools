import nakai/html.{div}
import nakai/html/attrs.{class}

pub fn page() -> html.Node(t) {
  div(
    [
      class(
        "w-full lg:min-h-[80vh] container mx-16 lg:grid lg:grid-cols-2 lg:items-center lg:gap-6 px-3 lg:px-2 lg:mt-0",
      ),
    ],
    [
    ],
  )
}
