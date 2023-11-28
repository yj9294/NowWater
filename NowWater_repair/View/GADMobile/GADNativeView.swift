//
//  GADNativeView.swift
//  NowWater_repair
//
//  Created by yangjian on 2023/10/16.
//

import Foundation
import GADUtil
import SwiftUI
import GoogleMobileAds

struct NativeView: UIViewRepresentable {
    let model: GADNativeViewModel
    func makeUIView(context: UIViewRepresentableContext<NativeView>) -> UIView {
        return model.view
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<NativeView>) {
        if let uiView = uiView as? UINativeAdView {
            uiView.refreshUI(ad: model.ad?.nativeAd)
        }
    }
}

struct GADNativeViewModel: Equatable {
    static func == (lhs: GADNativeViewModel, rhs: GADNativeViewModel) -> Bool {
        lhs.ad?.nativeAd == rhs.ad?.nativeAd
    }
    
    let ad: NativeADModel?
    let view: UINativeAdView
    init(ad: NativeADModel? = nil, view: UINativeAdView) {
        self.ad = ad
        self.view = view
        self.view.refreshUI(ad: ad?.nativeAd)
    }
    
    static var None: GADNativeViewModel {
        GADNativeViewModel(view: UINativeAdView())
    }
}


class UINativeAdView: GADNativeAdView {

    init(){
        super.init(frame: UIScreen.main.bounds)
        setupUI()
        refreshUI(ad: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var adView: UIImageView = {
        let image = UIImageView(image: UIImage(named: "ad_tag"))
        return image
    }()
    
    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .gray
        imageView.layer.cornerRadius = 2
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14.0, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    
    lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11.0)
        label.textColor = .white
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    
    lazy var installLabel: UIButton = {
        let label = UIButton()
        label.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.setTitleColor(UIColor.white, for: .normal)
        label.layer.cornerRadius = 20
        label.layer.masksToBounds = true
        return label
    }()
}

extension UINativeAdView {
    func setupUI() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1

        addSubview(iconImageView)
        iconImageView.frame = CGRectMake(15, 12, 40, 40)
        
        
        addSubview(titleLabel)
        let width = self.bounds.size.width - iconImageView.frame.maxX - 12 - 4 - 21 - 16
        titleLabel.frame = CGRectMake(iconImageView.frame.maxX + 12, 14, width, 14)

        
        addSubview(adView)
        adView.frame = CGRectMake(titleLabel.frame.maxX + 4, 15, 21, 12)
        
        addSubview(subTitleLabel)
        subTitleLabel.frame = CGRectMake(titleLabel.frame.minX, titleLabel.frame.maxY + 8, width + 21 + 4, 12)

        
        addSubview(installLabel)
        let w = self.bounds.size.width - 32
        installLabel.frame = CGRectMake(16, iconImageView.frame.maxY + 12, w, 40)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupUI()
    }
    
    func refreshUI(ad: GADNativeAd? = nil) {
        self.nativeAd = ad
        self.backgroundColor = .clear
        self.adView.image = UIImage(named: "ad")
        self.installLabel.setTitleColor(.white, for: .normal)
        self.installLabel.backgroundColor = UIColor(named: "#24B6BF")
        self.subTitleLabel.textColor = UIColor(named: "#899395")
        self.titleLabel.textColor = UIColor(named: "#14162C")
        
        self.iconView = self.iconImageView
        self.headlineView = self.titleLabel
        self.bodyView = self.subTitleLabel
        self.callToActionView = self.installLabel
        self.installLabel.setTitle(ad?.callToAction, for: .normal)
        self.iconImageView.image = ad?.icon?.image
        self.titleLabel.text = ad?.headline
        self.subTitleLabel.text = ad?.body
        
        self.hiddenSubviews(hidden: self.nativeAd == nil)
        
        if ad == nil {
            self.isHidden = true
        } else {
            self.isHidden = false
        }
    }
    
    func hiddenSubviews(hidden: Bool) {
        self.iconImageView.isHidden = hidden
        self.titleLabel.isHidden = hidden
        self.subTitleLabel.isHidden = hidden
        self.installLabel.isHidden = hidden
        self.adView.isHidden = hidden
    }
}
