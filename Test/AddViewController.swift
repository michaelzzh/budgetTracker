//
//  AddViewController.swift
//  Test
//
//  Created by Zehao Zhang on 15/3/11.
//  Copyright (c) 2015年 Zehao Zhang. All rights reserved.
//

import UIKit

class AddViewController: UIViewController, addOptionsProtocol, bucketCellProtocol, SetUpProtocol {
    let screenSize:CGRect = UIScreen.mainScreen().bounds;
    let addOptionsMargin:CGFloat = 0.15;
    
    var scrollViewX:CGFloat = 0;
    var scrollViewY:CGFloat = 0;
    var scrollViewW:CGFloat = 0;
    var scrollViewH:CGFloat = 0;
    let scrollViewMarginProportion:CGFloat = 1;
    let scrollViewHeightProportion:CGFloat = 0.4;
    
    var bucketList:BucketList!
    
    let totalBudgetTopMargin:CGFloat = 0.1;
    var totalBudgetX:CGFloat = 0;
    var totalBudgetY:CGFloat = 0;
    var totalBudgetW:CGFloat = 0;
    var totalBudgetH:CGFloat = 0;
    
    var totalBudgetView:TotalBudgetView!
    
    var delete = false;
    var firstTime = true;
    
    var trackerModel:TrackerModel = TrackerModel();
    
    var selectedBucketModel:BucketModel!
    var selectedBucketName = "";
    
    @IBOutlet var addButton:UIButton!;
    @IBOutlet var deleteButton:UIButton!;
    @IBOutlet var addOptionsContainer:UIVisualEffectView!;
    @IBOutlet var addOptions:AddOptionsView!;
    @IBOutlet var firstTimeSetUp:FirstTimeView!;
    
    
    override func viewDidLoad() {
        println("ADDViewControllerVDL");
        super.viewDidLoad()
        self.setUpBucketList();
        self.setUpTotalBudgetView();
        self.setUpAddOptions(self.view.frame);
        self.setUpForFirstTime(self.view.frame);
        if(firstTime){
            firstTimeSetUp.hidden = false;
            addOptionsContainer.hidden = false;
        }else{
            self.setUpModel();
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //to do
    func setUpModel(){
        if(!firstTime){
            //to do, read from core data
            self.trackerModel.setTotalBudget(5000);
        }
    }
    
    //to do, read from core data
    func setTotalBudget(totalBudget: Double, hue:CGFloat){
        self.trackerModel.setTotalBudget(totalBudget);
        self.trackerModel.setMainHue(hue);
        self.totalBudgetView!.setTotalBudget(totalBudget);
        self.totalBudgetView.setColor(self.trackerModel.getMainColor());
        if(firstTime){
            firstTimeSetUp.hidden = true;
            addOptionsContainer.hidden = true;
            firstTime = false;
        }
    }
    
    func setUpTotalBudgetView(){
        let screenWidth = self.view.frame.width;
        let screenHeight = self.view.frame.height;
        totalBudgetX = 0;
        totalBudgetY = screenHeight * totalBudgetTopMargin;
        totalBudgetW = screenWidth + scrollViewMarginProportion;
        totalBudgetH = screenHeight * scrollViewHeightProportion - totalBudgetY - 2;
        totalBudgetView = TotalBudgetView(frame: CGRect(x: totalBudgetX, y: totalBudgetY, width: totalBudgetW, height: totalBudgetH));
        self.view.addSubview(totalBudgetView!);
    }
    
    func setUpBucketList(){
        let screenWidth = self.view.frame.width;
        let screenHeight = self.view.frame.height;
        scrollViewX = screenWidth * (1-scrollViewMarginProportion) / 2;
        scrollViewY = screenHeight * scrollViewHeightProportion;
        scrollViewW = screenWidth * scrollViewMarginProportion;
        scrollViewH = screenHeight - scrollViewY - scrollViewX;
        bucketList = BucketList(frame: CGRect(x: scrollViewX, y: scrollViewY, width: scrollViewW, height: scrollViewH));
        bucketList.bucketCellDelegate = self;
        self.view.addSubview(bucketList!);
    }
    
    func setUpAddOptions(frame:CGRect){
        var blurEffect:UIBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light);
        self.addOptionsContainer = UIVisualEffectView(effect: blurEffect);
        self.addOptionsContainer.frame = self.view.frame;
        var addOptionsX = frame.width * addOptionsMargin;
        var addOptionsY = frame.height * addOptionsMargin;
        var addOptionsW = frame.width * (1 - 2 * addOptionsMargin);
        var addOptionsH = frame.height * (1 - 2 * addOptionsMargin);
        var addOptionsFrame = CGRect(x: addOptionsX, y: addOptionsY, width: addOptionsW, height: addOptionsH);
        self.addOptions = AddOptionsView(frame: addOptionsFrame);
        self.view.addSubview(addOptionsContainer)
        self.view.addSubview(addOptions);
        addOptions.delegate = self;
        addOptions.hidden = true;
        addOptionsContainer.hidden = true;
    }
    
    func setUpFirstTime(frame:CGRect){
        var addOptionsX = frame.width * addOptionsMargin;
        var addOptionsY = frame.height * addOptionsMargin;
        var addOptionsW = frame.width * (1 - 2 * addOptionsMargin);
        var addOptionsH = frame.height * (1 - 2 * addOptionsMargin);
        var addOptionsFrame = CGRect(x: addOptionsX, y: addOptionsY, width: addOptionsW, height: addOptionsH);
        self.firstTimeSetUp = FirstTimeView(frame: addOptionsFrame);
        self.view.addSubview(firstTimeSetUp);
        firstTimeSetUp.delegate = self;
        firstTimeSetUp.hidden = true;
        addOptionsContainer.hidden = true;
    }
    
    @IBAction func addTapped(sender : AnyObject) {
        self.addOptions.setAvailableAmt(self.trackerModel.getAvailableBudget());
        self.addOptions.hidden = false;
        self.addOptionsContainer.hidden = false;
    }
    
    func displayNameAlert(name:String){
        let alertController = UIAlertController(title: "Name used", message:
            "Bucket:" + name + " has already been created", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func displayOverLimitAlert(){
        let alertController = UIAlertController(title: "Over Budget", message:
            "You have exceeded the totoal budget", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func emptyAlert(){
        let alertController = UIAlertController(title: "Name/Budget empty", message:
            "Name / Budget field cannot be emoty", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)

    }
    
    func addBucketCell(name: String, budget: Double, hue:CGFloat)->Bool{
        var result = self.trackerModel.addNewBucket(name, limit: budget, hue: hue)
        if(result == "success"){
            if(self.bucketList != nil){
                self.bucketList?.addNewBucket(name, limit: budget);
                var bucketColor = self.trackerModel.getColorWithBucket(name);
                self.bucketList?.setBucketColorWithName(name, color: bucketColor!);
            }
            self.addOptions.hidden = true;
            self.addOptionsContainer.hidden = true;
            return true;
        }else{
            if(result == "replicate"){
                self.displayNameAlert(name);
            }else{
                self.displayOverLimitAlert();
            }
            return false;
        }
    }
    
    func cancelAddOption() {
        self.addOptions.hidden = true;
        self.addOptionsContainer.hidden = true;
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "presentBucket"){
            let bucketViewController = segue.destinationViewController as BucketViewController;
            bucketViewController.bucketName = self.selectedBucketName;
            bucketViewController.tracker = self.trackerModel;
        }
    }
    
    @IBAction func deleteTapped(sender:AnyObject){
        if(!delete){
            self.deleteButton.setTitle("Cancel", forState: UIControlState.Normal);
            self.delete = true;
            self.bucketList.setDeleteMode(delete);
        }else{
            self.deleteButton.setTitle("Delete", forState: UIControlState.Normal);
            self.delete = false;
            self.bucketList.setDeleteMode(delete);
        }
    }
    
    func deleteBucketCell(bucket:BucketCell){
        self.bucketList!.deleteBucketCell(bucket);
    }
    
    func loadBucketsWithModel(){
        self.totalBudgetView.setSpending(self.trackerModel.getSpending());
        self.totalBudgetView.setColor(self.trackerModel.getMainColor());
        let buckets = self.trackerModel.getBuckets();
        for bucket in buckets{
            self.bucketList.setBucketColorWithName(bucket.getName(), color:bucket.getColor());
            self.bucketList.setBucketSpendingWithName(bucket.getName(), s:bucket.currentBalance());
        }
    }
    
    @IBAction func bucketTapped(sender:BucketCell){
        let bucket = sender;
        if(delete){
            self.deleteBucketCell(bucket);
        }else{
            self.selectedBucketName = sender.getName();
            self.goToBucketView();
        }
        
    }
    
    func goToBucketView(){
        self.performSegueWithIdentifier("presentBucket", sender: self);
    }
    
    @IBAction func unwindFromBucketViewController(segue: UIStoryboardSegue){
        println("unwind");
        self.loadBucketsWithModel();
    }
}