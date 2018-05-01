//
//  ViewController.swift
//  Project04
//
//  Created by Tyler Arnold on 5/1/18.
//  Copyright © 2018 Tyler Arnold. All rights reserved.
//

import Cocoa
import WebKit

class ViewController: NSViewController, WKNavigationDelegate, NSGestureRecognizerDelegate {

    var rows: NSStackView!
    var selectedWebView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //1: Create the stack view and add it to our view
        //this how to create a stack view via code.
        rows = NSStackView()
        //this line sets the stack view vertical because my default it is horizontal
        rows.orientation = .vertical
        //this line sets the statck view to fill the space equally
        rows.distribution = .fillEqually
        rows.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(rows)
        
        //2: Create Auto Layout constraints
        rows.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        rows.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        rows.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        rows.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        //3: Create an initial column that contains a single web view
        let column = NSStackView(views: [makeWebView()])
        column.distribution = .fillEqually
        
        //4: Add this column to the `rows` stack view
        rows.addArrangedSubview(column)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func urlEntered(_ sender: NSTextField){
        guard let selected = selectedWebView else { return }
        
        //attempt to convert the user's text into a url
        if let url = URL(string: sender.stringValue) {
            
            //it worked - load it!
            selected.load(URLRequest(url: url))
        }
    }
    
    @IBAction func navigationClicked(_ sender: NSSegmentedControl) {
        //make sure we have a web view selected
        guard let selected = selectedWebView else { return }
        
        if sender.selectedSegment == 0 {
            
            //back was tapped
            selected.goBack()

        } else {
            
            //forward was tapped
            selected.goForward()
        }
    }
    
    @IBAction func adjustRows(_ sender: NSSegmentedControl) {
        
        if sender.selectedSegment == 0 {
            
            //we're adding a row
            
            //count how many columns we have so far
            let columnCount = (rows.arrangedSubviews[0] as! NSStackView).arrangedSubviews.count
            
            //make a new array of web views that contain the correct number of columns
            let viewArray = (0 ..< columnCount).map { _ in makeWebView() }
            
            //use that web view to create a new stack view
            let row = NSStackView(views: viewArray)
            
            //make the stack view size its children equally, then add it to our rows array
            row.distribution = .fillEqually
            rows.addArrangedSubview(row)
        } else {
            
            //we're deleteing a row
            
            //make sure we have at least two rows
            guard rows.arrangedSubviews.count > 1 else { return }
            
            //pull out the final row, and make sure its a stack view
            guard let rowToRemove = rows.arrangedSubviews.last as? NSStackView else { return }
            
            //loop through each web view in the row, removing it from the screen
            for cell in rowToRemove.arrangedSubviews {
                
                cell.removeFromSuperview()
            }
            
            //finally, remove the whole stack view row
            rows.removeArrangedSubview(rowToRemove)
        }
    }
    
    @IBAction func adjustColumns(_ sender: NSSegmentedControl) {
        
        if sender.selectedSegment == 0 {
            //we need to add a column
            for case let row as NSStackView in rows.arrangedSubviews {
            
                //loop over each row and add a new web view to it
                row.addArrangedSubview(makeWebView())
            }
        } else {
            
            //we need to delete a column
            
            //pull out the first of our rows
            guard let firstRow = rows.arrangedSubviews.first as? NSStackView else { return }
            
            //make sure it has at least two columns
            guard firstRow.arrangedSubviews.count > 1 else { return }
            
            //if we are still here it means it is safe to delete a column
            for case let row as NSStackView in rows.arrangedSubviews {
                
                //loop over every row
                if let last = row.arrangedSubviews.last {
                    
                    //pull out the last web view in this column and reomve it using the two-step process
                    row.removeArrangedSubview(last)
                    last.removeFromSuperview()
                    
                }
            }
        }
    }

    func makeWebView() -> NSView {
        let webView = WKWebView()
        webView.navigationDelegate = self
        webView.wantsLayer = true
        webView.load(URLRequest(url: URL(string: "https://www.apple.com")!))
        
//        2 ways to diambiguate clicks
        
//        let recognizer = NSClickGestureRecognizer(target: self, action: #selector(webViewClicked))
//        recognizer.numberOfClicksRequired = 2
//        webView.addGestureRecognizer(recognizer)
//        return webView
        
        let recognizer = NSClickGestureRecognizer(target: self, action: #selector(webViewClicked))
        recognizer.delegate = self
        webView.addGestureRecognizer(recognizer)
        
        return webView
    }
    
    func select(webView: WKWebView) {
        
        selectedWebView = webView
        selectedWebView.layer?.borderWidth = 4
        selectedWebView.layer?.borderColor = NSColor.blue.cgColor
        
        if let WindowController = view.window?.windowController as? WindowController {
            
            WindowController.addressEntry.stringValue = selectedWebView.url?.absoluteString ?? ""
        }
    }
    
    @objc func webViewClicked(recognizer: NSClickGestureRecognizer) {
        
        //get the web view that triggered this method
        guard let newSelectedWevView = recognizer.view as? WKWebView else { return }
        
        //deselect the currently selected web view if there is one
        if let selected = selectedWebView {
            selected.layer?.borderWidth = 0
        }
        
        //select the new one
        select(webView: newSelectedWevView)
    }
    
    func gestureRecognizer(_ gestureRecognizder: NSGestureRecognizer, shouldAttemptToRecognizeWith event: NSEvent) -> Bool {
        if gestureRecognizder.view == selectedWebView {
            return false
        } else {
            return true
        }
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        guard webView == selectedWebView else { return }
        
        if let windowController = view.window?.windowController as? WindowController {
            windowController.addressEntry.stringValue = webView.url?.absoluteString ?? ""
        }
    }
}

