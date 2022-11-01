//
//  PolicyResolverTests.swift
//  
//
//  Created by Jann Driessen on 01.11.22.
//

import XCTest
import BigInt
import Core

@testable import web3swift

final class PolicyResolverTests: XCTestCase {

    func testResolveAllForEIP1159Transaction() async throws {
        let web3 = await Web3.InfuraMainnetWeb3(accessToken: Constants.infuraToken)
        let resolver = PolicyResolver(provider: web3.provider)
        var tx = CodableTransaction(
            type: .eip1559,
            to: EthereumAddress("0xb47292B7bBedA4447564B8336E4eD1f93735e7C7")!,
            chainID: web3.provider.network!.chainID,
            value: Utilities.parseToBigUInt("0.1", units: .eth)!,
            gasLimit: 21_000
        )
        // Vitalik's address
        tx.from = EthereumAddress("0xAb5801a7D398351b8bE11C439e05C5B3259aeC9B")!
        try await resolver.resolveAll(for: &tx)
        print(tx.gasLimit)
        print(tx.nonce)
        XCTAssertGreaterThan(tx.gasLimit, 0)
        XCTAssertGreaterThan(tx.maxFeePerGas ?? 0, 0)
        XCTAssertGreaterThan(tx.maxPriorityFeePerGas ?? 0, 0)
        XCTAssertGreaterThan(tx.nonce, 0)
    }

    func testResolveAllForLegacyTransaction() async throws {
        let web3 = await Web3.InfuraMainnetWeb3(accessToken: Constants.infuraToken)
        let resolver = PolicyResolver(provider: web3.provider)
        var tx = CodableTransaction(
            type: .legacy,
            to: EthereumAddress("0xb47292B7bBedA4447564B8336E4eD1f93735e7C7")!,
            chainID: web3.provider.network!.chainID,
            value: Utilities.parseToBigUInt("0.1", units: .eth)!,
            gasLimit: 21_000
        )
        // Vitalik's address
        tx.from = EthereumAddress("0xAb5801a7D398351b8bE11C439e05C5B3259aeC9B")!
        try await resolver.resolveAll(for: &tx)
        print(tx.gasLimit)
        print(tx.nonce)
        XCTAssertGreaterThan(tx.gasLimit, 0)
        XCTAssertGreaterThan(tx.gasPrice ?? 0, 0)
        XCTAssertGreaterThan(tx.nonce, 0)
    }

    func testResolveExact() async throws {
        let expectedNonce = BigUInt(42)
        let expectedGasLimit = BigUInt(22_000)
        let expectedBaseFee = BigUInt(20)
        let expectedPriorityFee = BigUInt(9)
        let web3 = await Web3.InfuraMainnetWeb3(accessToken: Constants.infuraToken)
        let resolver = PolicyResolver(provider: web3.provider)
        var tx = CodableTransaction(
            type: .eip1559,
            to: EthereumAddress("0xb47292B7bBedA4447564B8336E4eD1f93735e7C7")!,
            chainID: web3.provider.network!.chainID,
            value: Utilities.parseToBigUInt("0.1", units: .eth)!,
            gasLimit: 21_000
        )
        // Vitalik's address
        tx.from = EthereumAddress("0xAb5801a7D398351b8bE11C439e05C5B3259aeC9B")!
        tx.gasLimitPolicy = .manual(expectedGasLimit)
        tx.maxFeePerGasPolicy = .manual(expectedBaseFee)
        tx.maxPriorityFeePerGasPolicy = .manual(expectedPriorityFee)
        tx.noncePolicy = .exact(expectedNonce)
        try await resolver.resolveAll(for: &tx)
        XCTAssertEqual(tx.gasLimit, expectedGasLimit)
        XCTAssertEqual(tx.maxFeePerGas, expectedBaseFee)
        XCTAssertEqual(tx.maxPriorityFeePerGas, expectedPriorityFee)
        XCTAssertEqual(tx.nonce, expectedNonce)
    }
}
