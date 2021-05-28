//
//  MainViewController.swift
//  Example
//
//  Created by Vladislav Grigoryev on 19.11.2020.
//  Copyright © 2020 GORA Studio. https://gora.studio
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation
import UIKit
import AVKit
import StoreKit

final class MainViewController: ViewController {

  static let cellResuseIdentifier = "Cell"
  
  override public var shouldAutorotate: Bool {
    return false
  }
  
  override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
      return .landscapeLeft
  }
  
  override public var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
    return .landscapeLeft
  }

  typealias Item = (title: String, controller: ControllableViewController.Type)
  let items: [Item] = {
    var items = [Item]()
    items.append((title: "ARKit Example", controller: ARKitViewController.self))
    items.append((title: "SceneKit Example", controller: SceneKitViewController.self))
    items.append((title: "RealityKit Example", controller: RealityKitViewController.self))
    items.append( (title: "Metal Example", controller: MetalViewController.self))
    return items
  }()

  // swiftlint:disable force_cast
  lazy var tableView: UITableView = view as! UITableView
  // swiftlint:enable force_cast

  override func loadView() { view = UITableView() }

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: Self.cellResuseIdentifier)
  }
}

extension MainViewController: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    items.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let item = items[indexPath.row]
    let cell = tableView.dequeueReusableCell(
      withIdentifier: Self.cellResuseIdentifier,
      for: indexPath
    )
    cell.selectionStyle = .none
    cell.accessoryType = .disclosureIndicator
    cell.textLabel?.text = item.title
    return cell
  }
}

extension MainViewController: UITableViewDelegate {

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let item = items[indexPath.row]
    let contentController = item.controller.init()
    let controlsController = ControlsViewController(contentController)
    controlsController.modalPresentationStyle = .fullScreen
    controlsController.delegate = self
    navigationController?.present(controlsController, animated: false, completion: nil)
//    navigationController?.pushViewController(controlsController, animated: true)
  }
}

//MARK: - UIApplication Extension
extension UIApplication {
    class func topViewController(viewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = viewController as? UINavigationController {
            return topViewController(viewController: nav.visibleViewController)
        }
        if let tab = viewController as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(viewController: selected)
            }
        }
        if let presented = viewController?.presentedViewController {
            return topViewController(viewController: presented)
        }
        return viewController
    }
}

extension MainViewController: ControlsViewControllerDelegate {

  func controlsViewControllerDidTakePhoto(_ photo: UIImage) {
    let controller = PhotoPreviewController(photo: photo)
    navigationController?.pushViewController(controller, animated: true)
  }

  func controlsViewControllerDidTakeVideoAt(_ url: URL) {
    let controller = VideoPreviewController(videoURL: url)
    UIApplication.topViewController()?.present(controller, animated: false, completion: nil)
  }
}
