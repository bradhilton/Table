import UIKit
import PlaygroundSupport
import Table

class ViewController : UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
}

let viewController = ViewController()
PlaygroundPage.current.liveView = viewController

func ColoredRect(color: UIColor) -> View {
    return View { view in
        view.backgroundColor = color
    }
}

func Label(text: String) -> View {
    return View { (view: UILabel) in
        view.text = text
    }
}

func StackView(
    axis: NSLayoutConstraint.Axis = .horizontal,
    distribution: UIStackView.Distribution = .fill,
    alignment: UIStackView.Alignment = .fill,
    arrangedSubviews: [ArrangedSubview]
) -> View {
    return View { (view: UIStackView) in
        view.axis = axis
        view.distribution = distribution
        view.alignment = alignment
        view.arrangedSubviews = arrangedSubviews
    }
}

func updateView(with subviews: [Subview]) {
    UIView.animate(withDuration: 2) {
        viewController.view.subviews = subviews
    }
    viewController.view
}

updateView(with:
    [
        Subview(
            key: 0,
            constraints: [
                .centerX == parent.centerX,
                .centerY == parent.centerY
            ],
            view: StackView(
                axis: .vertical,
//                distribution: .fill,
//                alignment: .center,
                arrangedSubviews: [
                    ArrangedSubview(
                        key: 0,
                        constraints: [],
                        spacingAfterView: 0,
                        view: Label(text: "Hello, world!")
                    )
                ]
            )
        )
    ]
)

updateView(with:
    [
        Subview(
            key: 0,
            constraints: [
                .centerX == parent.centerX,
                .centerY == parent.centerY
            ],
            view: StackView(
                axis: .vertical,
                //                distribution: .fill,
                //                alignment: .center,
                arrangedSubviews: [
                    ArrangedSubview(
                        key: 0,
                        constraints: [],
                        spacingAfterView: 0,
                        view: Label(text: "Hello, world!")
                    ),
                    ArrangedSubview(
                        key: 1,
                        constraints: [],
                        spacingAfterView: 0,
                        view: Label(text: "Hello, Brad!")
                    )
                ]
            )
        )
    ]
)

updateView(with:
    [
        Subview(
            key: 0,
            constraints: [
                .centerX == parent.centerX,
                .centerY == parent.centerY
            ],
            view: StackView(
                axis: .vertical,
                //                distribution: .fill,
                //                alignment: .center,
                arrangedSubviews: [
                    ArrangedSubview(
                        key: 1,
                        constraints: [],
                        spacingAfterView: 0,
                        view: Label(text: "Hello, Brad!")
                    ),
                    ArrangedSubview(
                        key: 0,
                        constraints: [],
                        spacingAfterView: 0,
                        view: Label(text: "Hello, world!")
                    )
                ]
            )
        )
    ]
)

updateView(with:
    [
        Subview(
            key: 0,
            constraints: [
                .centerX == parent.centerX,
                .centerY == parent.centerY
            ],
            view: StackView(
                axis: .vertical,
                //                distribution: .fill,
                //                alignment: .center,
                arrangedSubviews: [
                    ArrangedSubview(
                        key: 1,
                        constraints: [
                            .height == 100
                        ],
                        spacingAfterView: 0,
                        view: Label(text: "Hello, Brad!")
                    ),
                    ArrangedSubview(
                        key: 0,
                        constraints: [],
                        spacingAfterView: 0,
                        view: Label(text: "Hello, world!")
                    )
                ]
            )
        )
    ]
)



updateView(with:
    [
        Subview(
            key: 0,
            constraints: [
                .centerX == parent.centerX,
                .centerY == parent.centerY
            ],
            view: StackView(
                axis: .vertical,
                //                distribution: .fill,
                //                alignment: .center,
                arrangedSubviews: [
                    ArrangedSubview(
                        key: 1,
                        constraints: [],
                        spacingAfterView: 0,
                        view: Label(text: "Hello, Brad!")
                    ),
                    ArrangedSubview(
                        key: 2,
                        constraints: [],
                        spacingAfterView: 0,
                        view: Label(text: "Hello, Lorraine!")
                    ),
                    ArrangedSubview(
                        key: 3,
                        constraints: [],
                        spacingAfterView: 0,
                        view: Label(text: "Hello, Kendra!")
                    ),
                    ArrangedSubview(
                        key: 0,
                        constraints: [],
                        spacingAfterView: 0,
                        view: Label(text: "Hello, world!")
                    )
                ]
            )
        )
    ]
)

updateView(with:
    [
        Subview(
            key: 0,
            constraints: [
                .centerX == parent.centerX,
                .centerY == parent.centerY
            ],
            view: StackView(
                axis: .vertical,
                //                distribution: .fill,
                //                alignment: .center,
                arrangedSubviews: [
                    ArrangedSubview(
                        key: 2,
                        constraints: [],
                        spacingAfterView: 0,
                        view: Label(text: "Hello, Lorraine!")
                    ),
                    ArrangedSubview(
                        key: 3,
                        constraints: [],
                        spacingAfterView: 0,
                        view: Label(text: "Hello, Kendra!")
                    ),
                    ArrangedSubview(
                        key: 0,
                        constraints: [],
                        spacingAfterView: 0,
                        view: Label(text: "Hello, world!")
                    )
                ]
            )
        )
    ]
)

updateView(with:
    [
        Subview(
            key: 0,
            constraints: [
                .centerX == parent.centerX,
                .centerY == parent.centerY
            ],
            view: StackView(
                axis: .vertical,
                //                distribution: .fill,
                //                alignment: .center,
                arrangedSubviews: [
                    ArrangedSubview(
                        key: 2,
                        constraints: [],
                        spacingAfterView: 0,
                        view: Label(text: "Hello, Lorraine!")
                    ),
                    ArrangedSubview(
                        key: 1,
                        constraints: [],
                        spacingAfterView: 0,
                        view: Label(text: "Hello, Brad!")
                    ),
                    ArrangedSubview(
                        key: 0,
                        constraints: [],
                        spacingAfterView: 0,
                        view: Label(text: "Hello, world!")
                    )
                ]
            )
        )
    ]
)

updateView(with:
    [
        Subview(
            key: 0,
            constraints: [
                .centerX == parent.centerX,
                .centerY == parent.centerY
            ],
            view: StackView(
                axis: .vertical,
                //                distribution: .fill,
                //                alignment: .center,
                arrangedSubviews: [
                    ArrangedSubview(
                        key: 2,
                        constraints: [],
                        spacingAfterView: 0,
                        view: Label(text: "Hello, Lorraine!")
                    ),
                    ArrangedSubview(
                        key: 3,
                        constraints: [],
                        spacingAfterView: 0,
                        view: Label(text: "Hello, Kendra!")
                    ),
                    ArrangedSubview(
                        key: 0,
                        constraints: [],
                        spacingAfterView: 0,
                        view: Label(text: "Hello, world!")
                    )
                ]
            )
        )
    ]
)

updateView(with:
    [
        Subview(
            key: 0,
            constraints: [
                .centerX == parent.centerX,
                .centerY == parent.centerY
            ],
            view: StackView(
                axis: .vertical,
                //                distribution: .fill,
                //                alignment: .center,
                arrangedSubviews: [
                    ArrangedSubview(
                        key: 2,
                        constraints: [],
                        spacingAfterView: 0,
                        view: Label(text: "Hello, Lorraine!")
                    ),
                    ArrangedSubview(
                        key: 3,
                        constraints: [],
                        spacingAfterView: 0,
                        view: Label(text: "Hello, Kendra!")
                    ),
                    ArrangedSubview(
                        key: 0,
                        constraints: [],
                        spacingAfterView: 0,
                        view: Label(text: "Hello, world!")
                    ),
                    ArrangedSubview(key: 1, constraints: [], view: Label(text: "Hello, Brad!"))
                ]
            )
        )
    ]
)



updateView(with:
    [
        Subview(
            key: 0,
            constraints: [
                .centerX == parent.centerX,
                .centerY == parent.centerY
            ],
            view: StackView(
                axis: .horizontal,
                //                distribution: .fill,
                //                alignment: .center,
                arrangedSubviews: [
                    ArrangedSubview(
                        key: 2,
                        constraints: [],
                        spacingAfterView: 0,
                        view: Label(text: "Hello, Lorraine!")
                    ),
                    ArrangedSubview(
                        key: 3,
                        constraints: [],
                        spacingAfterView: 5,
                        view: Label(text: "Hello, Kendra!")
                    ),
                    ArrangedSubview(
                        key: 0,
                        constraints: [],
                        spacingAfterView: 0,
                        view: Label(text: "Hello, world!")
                    ),
                    ArrangedSubview(key: 1, constraints: [], view: Label(text: "Hello, Brad!"))
                ]
            )
        )
    ]
)

updateView(with:
    [
        Subview(
            key: 0,
            constraints: [
                .centerX == parent.centerX,
                .centerY == parent.centerY
            ],
            view: StackView(
                axis: .vertical,
                //                distribution: .fill,
                //                alignment: .center,
                arrangedSubviews: [
                    ArrangedSubview(
                        key: 2,
                        constraints: [],
                        spacingAfterView: 0,
                        view: Label(text: "Hello, Lorraine!")
                    ),
                    ArrangedSubview(
                        key: 3,
                        constraints: [],
                        spacingAfterView: 0,
                        view: Label(text: "Hello, Kendra!")
                    ),
                    ArrangedSubview(
                        key: 0,
                        constraints: [],
                        spacingAfterView: 0,
                        view: Label(text: "Hello, world!")
                    ),
                    ArrangedSubview(key: 1, constraints: [], view: Label(text: "Hello, Brad!"))
                ]
            )
        )
    ]
)

let stackView = UIStackView()

stackView.distribution
print(stackView.distribution == .fill)
stackView.alignment == .leading
stackView.alignment == .center
stackView.alignment == .fill
stackView.axis == .horizontal

updateView(with:
    [
        Subview(
            key: 0,
            constraints: [
                .centerX == parent.centerX,
                .centerY == parent.centerY
            ],
            view: StackView(
                axis: .vertical,
                distribution: .fill,
                alignment: .center,
                arrangedSubviews: [
                    ArrangedSubview(
                        key: 2,
                        constraints: [],
                        spacingAfterView: 20,
                        view: Label(text: "Hello, Lorraine!")
                    ),
                    ArrangedSubview(
                        key: 3,
                        constraints: [],
                        spacingAfterView: 5,
                        view: Label(text: "Hello, Kendra!")
                    ),
                    ArrangedSubview(
                        key: 0,
                        constraints: [],
                        spacingAfterView: -10,
                        view: Label(text: "Hello, world!")
                    ),
                    ArrangedSubview(key: 1, constraints: [], view: Label(text: "Hello, Brad!"))
                ]
            )
        )
    ]
)

updateView(with:
    [
        Subview(
            key: 0,
            constraints: [
                .centerX == parent.centerX,
                .centerY == parent.centerY
            ],
            view: StackView(
                axis: .vertical,
                distribution: .fill,
                alignment: .center,
                arrangedSubviews: [
                    ArrangedSubview(key: 1, constraints: [], view: Label(text: "Hello, Brad!")),
                    ArrangedSubview(
                        key: 0,
                        constraints: [],
                        spacingAfterView: 0,
                        view: Label(text: "Hello, world!")
                    ),
                    ArrangedSubview(
                        key: 3,
                        constraints: [],
                        spacingAfterView: 0,
                        view: Label(text: "Hello, Kendra!")
                    ),
                    ArrangedSubview(
                        key: 2,
                        constraints: [],
                        spacingAfterView: 0,
                        view: Label(text: "Hello, Lorraine!")
                    ),
                ]
            )
        )
    ]
)
