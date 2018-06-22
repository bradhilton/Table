//
//  KeyedTransitioningDelegate.swift
//  Table
//
//  Created by Bradley Hilton on 6/15/18.
//  Copyright © 2018 Brad Hilton. All rights reserved.
//

extension UIViewController {
    
    public var keyedTransitioningDelegate: KeyedTransitioningDelegate {
        return storage[\.keyedTransitioningDelegate, default: KeyedTransitioningDelegate(with: self)]
    }
    
}

public class KeyedTransitioningDelegate : NSObject, UIViewControllerTransitioningDelegate {
    
    public var keys: [AnyHashable] = []
    public var duration: TimeInterval = 0.25
    
    init(with viewController: UIViewController) {
        super.init()
        viewController.modalPresentationStyle = .fullScreen
        viewController.transitioningDelegate = self
    }
    
    public func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        return KeyedPresentationAnimatedTransitioning(keys: keys, duration: duration)
    }
    
}

struct Transition {
    let from: View
    let to: View
    
    struct View {
        let view: UIView
        let snapshot: UIView
        let convertedFrame: CGRect
        
        init(_ view: UIView, with containerView: UIView) {
            self.view = view
            self.snapshot = view.snapshotView(afterScreenUpdates: true)!
            self.convertedFrame = containerView.convert(view.bounds, from: view)
        }
        
    }
    
    func addViews(to containerView: UIView) {
        from.view.isHidden = true
        to.view.isHidden = true
        containerView.addSubview(from.snapshot)
        from.snapshot.frame = from.convertedFrame
        containerView.addSubview(to.snapshot)
        to.snapshot.frame = from.convertedFrame
        to.snapshot.alpha = 0
    }
    
    func animateViews() {
        from.snapshot.frame = to.convertedFrame
        from.snapshot.alpha = 0
        to.snapshot.frame = to.convertedFrame
        to.snapshot.alpha = to.view.alpha
    }
    
    func complete() {
        from.view.isHidden = false
        to.view.isHidden = false
        from.snapshot.removeFromSuperview()
        to.snapshot.removeFromSuperview()
    }
    
}

class KeyedPresentationAnimatedTransitioning : NSObject, UIViewControllerAnimatedTransitioning {
    
    let keys: [AnyHashable]
    let duration: TimeInterval
    
    init(keys: [AnyHashable], duration: TimeInterval) {
        self.keys = keys
        self.duration = duration
    }
    
    func transitionDuration(using context: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using context: UIViewControllerContextTransitioning) {
        let containerView = context.containerView
        let fromView = context.view(forKey: .from)!
        let toView = context.view(forKey: .to)!
        let toViewController = context.viewController(forKey: .to)!
        
        containerView.addSubview(toView)
        let finalFrame = context.finalFrame(for: toViewController)
        toView.frame = finalFrame
        
        let transitions = self.keys.compactMap { key in
            fromView.firstSubview(key: key).flatMap { fromView in
                toViewController.firstSubview(key: key).map { toView in
                    Transition(
                        from: Transition.View(fromView, with: containerView),
                        to: Transition.View(toView, with: containerView)
                    )
                }
            }
        }
        transitions.forEach { $0.addViews(to: containerView) }
        
        toView.frame = CGRect(origin: CGPoint(x: finalFrame.origin.x, y: finalFrame.origin.y + finalFrame.size.height), size: finalFrame.size)
        
        UIView.animate(
            withDuration: duration,
            delay: 0.0,
            options: [.curveEaseOut],
            animations: {
                toView.frame = finalFrame
                transitions.forEach { $0.animateViews() }
            },
            completion: { _ in
                transitions.forEach { $0.complete() }
                context.completeTransition(true)
            }
        )
        
    }
    
}
