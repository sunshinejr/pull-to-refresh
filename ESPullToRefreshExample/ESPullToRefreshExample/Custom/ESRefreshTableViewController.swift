//
//  ESRefreshTableViewController.swift
//  ESPullToRefreshExample
//
//  Created by lihao on 16/8/18.
//  Copyright © 2016年 egg swift. All rights reserved.
//

import UIKit

public class ESRefreshTableViewController: UITableViewController {

    public var array = [String]()
    public var page = 1
    public var type: ESRefreshExampleType = .defaulttype
    
    public override init(style: UITableViewStyle) {
        super.init(style: style)
        for num in 1...8{
            if num % 2 == 0 && arc4random() % 4 == 0 {
                self.array.append("info")
            } else {
                self.array.append("photo")
            }
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = UIColor.init(red: 244.0 / 255.0, green: 245.0 / 255.0, blue: 245.0 / 255.0, alpha: 1.0)
        
        self.tableView.registerNib(UINib.init(nibName: "ESRefreshTableViewCell", bundle: nil), forCellReuseIdentifier: "ESRefreshTableViewCell")
        self.tableView.registerNib(UINib.init(nibName: "ESPhotoTableViewCell", bundle: nil), forCellReuseIdentifier: "ESPhotoTableViewCell")
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 560
        self.tableView.separatorStyle = .None
        self.tableView.separatorColor = UIColor.clearColor()
        
        var header: protocol<ESRefreshProtocol, ESRefreshAnimatorProtocol>
        var footer: protocol<ESRefreshProtocol, ESRefreshAnimatorProtocol>
        switch type {
        case .meituan:
            header = MTRefreshHeaderAnimator.init(frame: CGRect.zero)
            footer = MTRefreshFooterAnimator.init(frame: CGRect.zero)
        case .wechat:
            header = WCRefreshHeaderAnimator.init(frame: CGRect.zero)
            footer = ESRefreshFooterAnimator.init(frame: CGRect.zero)
        default:
            header = ESRefreshHeaderAnimator.init(frame: CGRect.zero)
            footer = ESRefreshFooterAnimator.init(frame: CGRect.zero)
            break
        }
        
        self.tableView.es_addPullToRefresh(header) { [weak self] in
            self?.refresh()
        }
        self.tableView.es_addInfiniteScrolling(footer) { [weak self] in
            self?.loadMore()
        }
        self.tableView.refreshIdentifier = String.init(type)
        self.tableView.expiredTimeInterval = 20.0
        
        Dispatch.after(1.0) {
            self.tableView.es_autoPullToRefresh()
        }
    }

    private func refresh() {
        Dispatch.after(3.0) {
            self.page = 1
            self.array.removeAll()
            for num in 1...8{
                if num % 2 == 0 && arc4random() % 4 == 0 {
                    self.array.append("info")
                } else {
                    self.array.append("photo")
                }
            }
            self.tableView.reloadData()
            self.tableView.es_stopPullToRefresh()
        }
    }
    
    private func loadMore() {
        Dispatch.after(3.0) {
            self.page += 1
            if self.page <= 3 {
                for num in 1...8{
                    if num % 2 == 0 && arc4random() % 4 == 0 {
                        self.array.append("info")
                    } else {
                        self.array.append("photo")
                    }
                }
                self.tableView.reloadData()
                self.tableView.es_stopLoadingMore()
            } else {
                self.tableView.es_noticeNoMoreData()
            }
        }
    }
    
    // MARK: - Table view data source
    public override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }

    public override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
    

    public override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        let string = self.array[indexPath.row]
        if string == "info" {
            cell = tableView.dequeueReusableCellWithIdentifier("ESRefreshTableViewCell", forIndexPath: indexPath)
        } else if string == "photo" {
            cell = tableView.dequeueReusableCellWithIdentifier("ESPhotoTableViewCell", forIndexPath: indexPath)
            if let cell = cell as? ESPhotoTableViewCell {
                cell.updateContent(indexPath)
            }
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("UITableViewCell", forIndexPath: indexPath)
        }
        return cell
    }
    
    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.navigationController?.pushViewController(WebViewController.init(), animated: true)
    }
}
