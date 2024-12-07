// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.27;

import {ClearSafeStorage} from "./ClearSafeStorage.sol";
import {CompatibilityFallbackHandler} from
    "@safe-global/safe-smart-account/contracts/handler/CompatibilityFallbackHandler.sol";
import {ISafe} from "@safe-global/safe-smart-account/contracts/interfaces/ISafe.sol";
import {Enum} from "@safe-global/safe-smart-account/contracts/libraries/Enum.sol";

contract DelegateAccountFallbackHandler is CompatibilityFallbackHandler, ClearSafeStorage {
    error InvalidSender(address sender, address expected);

    event OnRedelegation();

    function accountId() external view returns (string memory) {
        return "SafeSmartAccount.v1.4.1";
    }

    function accountStorageBases() external view returns (bytes32[] memory) {
        return new bytes32[](0);
    }

    function onRedelegation() external returns (bool) {
        if (_manager() != _msgSender()) {
            revert InvalidSender(_msgSender(), _manager());
        }

        bool success = ISafe(_manager()).execTransactionFromModule(
            address(this),
            0,
            abi.encode(this.clearSafeStorageDelegateCallReciever.selector),
            Enum.Operation.DelegateCall
        );

        if (!success) {
            return false;
        }

        emit OnRedelegation();
        return true;
    }
}
