//
//  FlexViewController.swift
//  AlertBuilder
//
//  Created by Bradley Hilton on 3/15/18.
//

open class FlexViewController : UIViewController {
    
    public var flexView: FlexView {
        return view as! FlexView
    }
    
    override open func loadView() {
        view = FlexView()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.performWithoutAnimation {
            view.layoutSubviews()
        }
    }
    
//    open override func viewDidLoad() {
//        super.viewDidLoad()
//        view.addSubview(flexView)
//        flexView.translatesAutoresizingMaskIntoConstraints = false
//        if #available(iOS 11.0, *) {
//            NSLayoutConstraint.activate([
//                flexView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
//                flexView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//                flexView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
//                flexView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
//            ])
//        } else {
//            NSLayoutConstraint.activate([
//                flexView.leftAnchor.constraint(equalTo: view.leftAnchor),
//                flexView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
//                flexView.rightAnchor.constraint(equalTo: view.rightAnchor),
//                flexView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.bottomAnchor)
//            ])
//        }
//    }
    
}
