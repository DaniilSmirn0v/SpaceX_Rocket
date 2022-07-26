//
//  RocketInfoPresenter.swift
//  SpaceX_Rocket
//
//  Created by Elena Noack on 17.06.22.
//

import UIKit

protocol RocketViewProtocol: AnyObject {
    func success()
    func failure(error: NetworkError)
    func setupDisplay()
}

protocol RocketInfoPresenterProtocol: AnyObject {
    init(view: RocketViewProtocol, networkService: NetworkServiceProtocol, router: RouterProtocol)
    func tapLaunchesButton(rocketId: String)
    func tapSettingButton()
    var rockets: [Rocket]? { get set }
    var rocketsImageURL: [String]? { get set }
    var rocketsImage: UIImage { get set }
    func reload()
    func fetchRocketsData()
    func localeСountryName() -> String?
}

class RocketInfoPresenter: RocketInfoPresenterProtocol {

    let view: RocketViewProtocol?
    let networkService: NetworkServiceProtocol?
    var router: RouterProtocol?
    var rockets: [RocketData]?
    var rocketsImageURL: [String]?
    var rocketsImage = UIImage()
    let defaults = UserDefaultsStorage()
    
    required init(view: RocketViewProtocol, networkService: NetworkServiceProtocol, router: RouterProtocol) {
        self.view = view
        self.networkService = networkService
        self.router = router
        fetchRocketsData()
    }
    
    func tapLaunchesButton(rocketId: String) {
        router?.openLaunchVC(rocketId: rocketId)
    }
    
    func tapSettingButton() {
        router?.openSettingsVC()
    }
    
    func fetchRocketsData() {
        networkService?.fetchRocketsData { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case let .success(rocket):
                    self.rockets = rocket
                    self.rocketsImageURL = self.rockets?.first?.image
                    self.fetchRocketsImage()
                    self.view?.success()
                case let .failure(error):
                    self.view?.failure(error: error)
                }
                return
            }
        }
    }
    
    func fetchRocketsImage() {
        guard let rocketsImageURL = rocketsImageURL?.first else { return }
        networkService?.fetchRocketImage(with: rocketsImageURL, completion: { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case let .success(image):
                    self.rocketsImage = image ?? UIImage()
                    self.view?.setupDisplay()
                case let .failure(error):
                    self.view?.failure(error: error)
                }
                return
            }
        })
    }
    
    func reload() {
        router?.saveCompletion = {
            self.view?.success()
        }
    }
    
    func localeСountryName() -> String? {
        let countries = ["United States" : "США",
                         "Republic of the Marshall Islands" : "Маршалловы о-ва"]
        let key = self.rockets?.first?.country
        let countryName = countries.filter { $0.key == key }
        return countryName.values.first
    }
}



