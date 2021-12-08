import RxBus
import RxSwift
import UIKit

// Defining Events struct
struct Events {
    struct Input {
        let payload: String
    }
    
    struct Output {
        let payload: String
    }
}

struct TestObject1 {
    let payload: String
}

struct TestObject2 {
    let payload: String
}

struct PriorityObject {}

// Defining Custom Notification
extension Notification.Name {
    static let ViewControllerDidLoad = Notification.Name("ViewControllerDidLoadNotification")
}

class ViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!

    private var disposeBag = DisposeBag()

    let bus = RxBus()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Event subscription/posting
        bus.register(event: Events.Input.self)
            .subscribe { event in
                print("input, payload = \(event.element!.payload) \n")
            }.disposed(by: disposeBag)
        
        bus.post(event: Events.Input(payload: "payload1"))
        
//        print("\(bus.description)")
        
        bus.register(event: TestObject1.self)
            .subscribe(onNext: { event in
                print("s1 event = \(event.payload) \n")
            }).disposed(by: disposeBag)
        
        bus.register(event: TestObject1.self)
            .subscribe(onNext: { event in
                print("s2 event = \(event.payload) \n")
            }).disposed(by: disposeBag)
        
        bus.post(event: TestObject1(payload: "test obj1 payload"))
        
//        print("\(bus.description)")
        
        // Sticky events
        bus.post(event: TestObject2(payload: "test1 obj2 payload"), sticky: true)
        
        bus.register(event: TestObject2.self, sticky: true)
            .subscribe(onNext: { event in
                print("k1 event = \(event.payload) \n")
            }).disposed(by: disposeBag)
        
        bus.register(event: TestObject2.self)
            .subscribe(onNext: { event in
                print("k2 event = \(event.payload) \n")
            }).disposed(by: disposeBag)
        
        bus.post(event: TestObject2(payload: "test2 obj2 payload"), sticky: true)
        
//        print("\(bus.description)")
        
        bus.post(event: Events.Output(payload: "payload2"), sticky: true)
        
        bus.register(event: Events.Output.self, sticky: true)
            .subscribe { event in
                print("output, payload = \(event.element!.payload) \n")
            }.disposed(by: disposeBag)
        
//        print("\(bus.description)")
        
        // Subscription priority
        bus.register(event: PriorityObject.self, sticky: false, priority: -1)
            .subscribe(onNext: { event in
                print("\(event) priority -1 \n")
            }).disposed(by: disposeBag)
        
        bus.register(event: PriorityObject.self, sticky: false, priority: 1)
            .subscribe(onNext: { event in
                print("\(event) priority 1 \n")
        }).disposed(by: disposeBag)
        
        bus.register(event: PriorityObject.self)
            .subscribe(onNext: { event in
                print("\(event) priority default \n")
        }).disposed(by: disposeBag)
        
        bus.post(event: PriorityObject())
        
//        print("\(bus.description)")
        
        // System Notification subscription
        bus.register(notificationName: UIResponder.keyboardWillShowNotification).subscribe { event in
            print("\(event.element!.name.rawValue), userInfo: \(event.element!.userInfo!) \n")
        }.disposed(by: disposeBag)

        textField.becomeFirstResponder()

//        print("\(bus.description)")
        
        // Custom Notification subscription/posting
        bus.post(notificationName: .ViewControllerDidLoad, userInfo: ["message": "test"], sticky: true)

        bus.register(notificationName: .ViewControllerDidLoad, sticky: true).subscribe { event in
            print("\(event.element!.name.rawValue), userInfo: \(event.element!.userInfo!) \n")
        }.disposed(by: disposeBag)
        
//        print("\(bus.description)")
        
        disposeBag = DisposeBag()
        
        print("\(bus.description)")
    }
}
