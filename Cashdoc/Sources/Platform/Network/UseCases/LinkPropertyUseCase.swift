//
//  LinkPropertyUseCase.swift
//  Cashdoc
//
//  Created by Oh Sangho on 07/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa

final class LinkPropertyUseCase {
    
    private let disposeBag = DisposeBag()
    private let provider = CashdocProvider<CertService>()
    
    func getAuthKey() -> Driver<String> {
        return provider
            .request(String.self, token: .getAuthKey)
            .asDriverOnErrorJustNever()
    }
    
    func importCertification(authKey: String?, fetching: PublishRelay<Int>, networkError: PublishRelay<Void>) -> Single<GetCertificateInfo> {
        return Single.create(subscribe: { [unowned self] (single) -> Disposable in
            guard let authKey = authKey,
                ReachabilityManager.reachability.connection != .unavailable else {
                networkError.accept(())
                return Disposables.create()
            }
            return self.provider.request(GetCertificateInfo.self, token: .getCertInfo(authKey: authKey))
                .subscribe(onSuccess: { (certInfo) in
                    
                    let rootPath: String = certInfo.bodyArea.certPath
                    let derFile: String = certInfo.bodyArea.certDerFile
                    let keyFile: String = certInfo.bodyArea.certKeyFile
                    
                    var cn = ""
                    if rootPath.contains("cn=") {
                        guard let tmpCN = rootPath.components(separatedBy: "cn=").last else {
                            fetching.accept(1)
                            return
                        }
                        let resultCN = String(format: "cn=%@", tmpCN)
                        cn = resultCN
                    }
                    
                    let certPath = String(format: "NPKI/%@", cn)
                    
                    let fileManager = FileManager.default
                    let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
                    
                    guard let certPathURL = documentsURL?.appendingPathComponent(certPath) else {
                        fetching.accept(1)
                        return
                    }
                    
                    do {
                        try fileManager.createDirectory(atPath: certPathURL.path,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
                        
                        let derPathURL = certPathURL.appendingPathComponent("signCert.der")
                        try derFile.hexadecimal?.write(to: derPathURL, options: .atomic)
                        
                        let keyPathURL = certPathURL.appendingPathComponent("signPri.key")
                        try keyFile.hexadecimal?.write(to: keyPathURL, options: .atomic)
                        fetching.accept(2)
                    } catch {
                        print("Couldn't Create Cert Directory Error : \(error.localizedDescription)")
                        fetching.accept(1)
                    }
                    
                }, onFailure: { (error) in
                    fetching.accept(1)
                    single(.failure(error))
                })
            
        })
        
    }
    
}
