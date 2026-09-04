//@compile-flags: --only-lint missing-events-arithmetic

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract MissingEventsArithmetic {
    address public owner = msg.sender;

    uint256 public buyPrice;
    uint256 public sellFeeBps;
    uint256 public cap;
    uint256 public rewardRate;
    uint256 public conditionallyEmittedValue;
    uint256 public selfIncrementedValue;
    uint256 public prefixIncrementedValue;
    uint256 public postfixDecrementedValue;
    uint256 public stateDelta;
    uint256 public plainValue;
    uint256 public fixedValue;
    uint256 public protectedOnlyValue;
    uint256 public senderObservedValue;
    uint256 public senderNonZeroValue;
    uint256 public wrongPolarityValue;
    mapping(address => uint256) public balances;

    event BuyPriceUpdated(uint256 newBuyPrice);
    event CapUpdated(uint256 newCap);
    event ConditionallyEmittedValueUpdated(uint256 newValue);
    event Touched();

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    modifier onlyOwnerViaCheck() {
        _checkOwner();
        _;
    }

    modifier onlyPositive(uint256 value) {
        require(value > 0, "not positive");
        _;
    }

    // SHOULD FAIL:

    function setBuyPrice(uint256 newBuyPrice) external onlyOwner {
        buyPrice = newBuyPrice; //~WARN: `buyPrice` is changed without an event but is used in arithmetic
    }

    function setSellFee(uint256 newFee) external onlyOwner {
        uint256 fee = newFee;
        sellFeeBps = fee; //~WARN: `sellFeeBps` is changed without an event but is used in arithmetic
    }

    function setCap(uint256 newCap) external onlyOwner {
        _setCap(newCap);
    }

    function _setCap(uint256 newCap) internal {
        cap = newCap; //~WARN: `cap` is changed without an event but is used in arithmetic
    }

    function increaseRewardRate(uint256 delta) external onlyOwner {
        rewardRate += delta; //~WARN: `rewardRate` is changed without an event but is used in arithmetic
    }

    function setBuyPriceOZStyle(uint256 newBuyPrice) external onlyOwnerViaCheck {
        buyPrice = newBuyPrice; //~WARN: `buyPrice` is changed without an event but is used in arithmetic
    }

    function setConditionallyEmittedValue(uint256 newValue, bool withEvent) external onlyOwner {
        if (withEvent) {
            conditionallyEmittedValue = newValue;
            emit ConditionallyEmittedValueUpdated(newValue);
        } else {
            conditionallyEmittedValue = newValue; //~WARN: `conditionallyEmittedValue` is changed without an event but is used in arithmetic
        }
    }

    function incrementSelf() external onlyOwner {
        selfIncrementedValue += 1; //~WARN: `selfIncrementedValue` is changed without an event but is used in arithmetic
    }

    function incrementByStateDelta() external onlyOwner {
        selfIncrementedValue += stateDelta; //~WARN: `selfIncrementedValue` is changed without an event but is used in arithmetic
    }

    function prefixIncrement() external onlyOwner {
        ++prefixIncrementedValue; //~WARN: `prefixIncrementedValue` is changed without an event but is used in arithmetic
    }

    function postfixDecrement() external onlyOwner {
        postfixDecrementedValue--; //~WARN: `postfixDecrementedValue` is changed without an event but is used in arithmetic
    }

    // Arithmetic usage that makes the values critical.

    function buyQuote(uint256 amount) external view returns (uint256) {
        return amount / buyPrice;
    }

    function feeQuote(uint256 amount) external view returns (uint256) {
        uint256 fee = sellFeeBps;
        return amount * fee / 10_000;
    }

    function cappedAmount(uint256 amount) external view returns (uint256) {
        return amount + cap;
    }

    function rewardQuote(uint256 amount) external view returns (uint256) {
        return _rewardQuote(amount, rewardRate);
    }

    function conditionallyEmittedQuote(uint256 amount) external view returns (uint256) {
        return amount * conditionallyEmittedValue;
    }

    function selfIncrementedQuote(uint256 amount) external view returns (uint256) {
        return amount + selfIncrementedValue;
    }

    function prefixIncrementedQuote(uint256 amount) external view returns (uint256) {
        return amount * prefixIncrementedValue;
    }

    function postfixDecrementedQuote(uint256 amount) external view returns (uint256) {
        return amount * postfixDecrementedValue;
    }

    function _rewardQuote(uint256 amount, uint256 rate) internal pure returns (uint256) {
        return amount * rate;
    }

    // SHOULD PASS:

    function setBuyPriceWithEvent(uint256 newBuyPrice) external onlyOwner {
        buyPrice = newBuyPrice;
        emit BuyPriceUpdated(newBuyPrice);
    }

    function setCapWithInternalEvent(uint256 newCap) external onlyOwner {
        _setCapWithEvent(newCap);
    }

    function _setCapWithEvent(uint256 newCap) internal {
        cap = newCap;
        emit CapUpdated(newCap);
    }

    function setWithUnrelatedEvent(uint256 newBuyPrice) external onlyOwner {
        emit Touched();
        buyPrice = newBuyPrice; //~WARN: `buyPrice` is changed without an event but is used in arithmetic
    }

    function unprotectedSetBuyPrice(uint256 newBuyPrice) external {
        buyPrice = newBuyPrice;
    }

    function setPlainValue(uint256 newValue) external onlyOwner {
        plainValue = newValue;
    }

    function readPlainValue() external view returns (uint256) {
        return plainValue;
    }

    function setFixedValue() external onlyOwner {
        fixedValue = 100;
    }

    function fixedQuote(uint256 amount) external view returns (uint256) {
        return amount * fixedValue;
    }

    function onlyPositiveSet(uint256 newFee) external onlyPositive(newFee) {
        sellFeeBps = newFee;
    }

    function setProtectedOnlyValue(uint256 newValue) external onlyOwner {
        protectedOnlyValue = newValue;
    }

    function protectedOnlyQuote(uint256 amount) external view onlyOwner returns (uint256) {
        return amount * protectedOnlyValue;
    }

    function observesSenderButDoesNotRestrict(uint256 newValue) external {
        if (msg.sender == owner) {
            newValue += 1;
        }
        senderObservedValue = newValue;
    }

    function senderObservedQuote(uint256 amount) external view returns (uint256) {
        return amount * senderObservedValue;
    }

    function requiresSenderNonZeroButDoesNotRestrict(uint256 newValue) external {
        require(msg.sender != address(0), "zero sender");
        senderNonZeroValue = newValue;
    }

    function senderNonZeroQuote(uint256 amount) external view returns (uint256) {
        return amount * senderNonZeroValue;
    }

    // Returning on the authorized branch is not access control, so this setter stays out of scope.
    function wrongPolaritySetWithEvent(uint256 newValue) external {
        if (msg.sender == owner) return;
        wrongPolarityValue = newValue;
        emit ConditionallyEmittedValueUpdated(newValue);
    }

    function wrongPolarityQuote(uint256 amount) external view returns (uint256) {
        return amount * wrongPolarityValue;
    }

    function setBalance(address account, uint256 amount) external onlyOwner {
        balances[account] = amount;
    }

    function balanceQuote(address account, uint256 amount) external view returns (uint256) {
        return balances[account] * amount;
    }

    constructor(uint256 initialBuyPrice) {
        buyPrice = initialBuyPrice;
    }

    function _checkOwner() internal view {
        if (owner != _msgSender()) revert();
    }

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }
}

contract MissingEventsArithmeticNoProtectedMutatingEntryPoint {
    address public owner = msg.sender;
    uint256 public price;

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    function setPrice(uint256 newPrice) external {
        price = newPrice;
    }

    function quote(uint256 amount) external view returns (uint256) {
        return amount * price;
    }

    function protectedQuote(uint256 amount) external view onlyOwner returns (uint256) {
        return amount / price;
    }
}

// Reproduction cases for oracle findings.

contract ReproEmittedEventIsSticky {
    address public owner = msg.sender;
    uint256 public price;
    event Touched();
    event PriceUpdated(uint256);

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function buyQuote(uint256 amount) external view returns (uint256) {
        return amount / price;
    }

    function setWithUnrelatedEmitBefore(uint256 newPrice) external onlyOwner {
        emit Touched();
        price = newPrice; //~WARN: `price` is changed without an event but is used in arithmetic
    }

    function setPriceWithEvent(uint256 newPrice) external onlyOwner {
        price = newPrice;
        emit PriceUpdated(newPrice);
    }
}

contract ReproReturnNotTerminator {
    address public owner = msg.sender;
    uint256 public price;
    event PriceUpdated(uint256);

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function buyQuote(uint256 amount) external view returns (uint256) {
        return amount / price;
    }

    function setWithReturnBeforeEmit(uint256 newPrice, bool skip) external onlyOwner {
        price = newPrice; //~WARN: `price` is changed without an event but is used in arithmetic
        if (skip) return;
        emit PriceUpdated(newPrice);
    }
}

interface IOracle {
    function getPrice() external view returns (uint256);
}

contract ReproTryClausesShareState {
    address public owner = msg.sender;
    uint256 public price;
    address public oracle;
    event PriceUpdated(uint256);

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function buyQuote(uint256 amount) external view returns (uint256) {
        return amount / price;
    }

    function setViaOracle(uint256 fallbackPrice) external onlyOwner {
        try IOracle(oracle).getPrice() returns (uint256 p) {
            price = p;
            emit PriceUpdated(p);
        } catch {
            price = fallbackPrice; //~WARN: `price` is changed without an event but is used in arithmetic
        }
    }
}

contract ReproUntaintedAssigns {
    address public owner = msg.sender;
    uint256 public price;
    uint256 public referencePrice;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function buyQuote(uint256 amount) external view returns (uint256) {
        return amount / price;
    }

    function setPriceFromStateVar() external onlyOwner {
        price = referencePrice; //~WARN: `price` is changed without an event but is used in arithmetic
    }

    function setPriceFromTimestamp() external onlyOwner {
        price = block.timestamp; //~WARN: `price` is changed without an event but is used in arithmetic
    }
}

contract ReproHelperReturnArithmetic {
    address public owner = msg.sender;
    uint256 public rate;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function _getRate() internal view returns (uint256) {
        return rate;
    }

    function rateQuote(uint256 amount) external view returns (uint256) {
        return amount * _getRate();
    }

    function setRate(uint256 newRate) external onlyOwner {
        rate = newRate; //~WARN: `rate` is changed without an event but is used in arithmetic
    }
}

contract ReproAccessGuardTooLoose {
    address public owner = msg.sender;
    uint256 public price;
    bool public flag;

    function buyQuote(uint256 amount) external view returns (uint256) {
        return amount / price;
    }

    function setWithNonDominatingGuard(uint256 newPrice) external {
        if (flag) require(msg.sender == owner, "not owner");
        price = newPrice;
    }
}

contract ReproMayExitNotMustExit {
    error NotOwner();

    address public owner = msg.sender;
    uint256 public price;
    bool public flag;

    function buyQuote(uint256 amount) external view returns (uint256) {
        return amount / price;
    }

    function setWithWeakGuard(uint256 newPrice) external {
        if (msg.sender != owner) {
            if (flag) revert NotOwner();
        }
        price = newPrice;
    }
}

contract ReproModifierBodyNotAnalyzed {
    address public owner = msg.sender;
    uint256 public price;
    event PriceUpdated(uint256);

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier emitAfter() {
        _;
        emit PriceUpdated(price);
    }

    function buyQuote(uint256 amount) external view returns (uint256) {
        return amount / price;
    }

    function setPriceWithModifierEvent(uint256 newPrice) external onlyOwner emitAfter {
        price = newPrice;
    }
}

contract ReproAccessCheckTooBroad {
    address public owner = msg.sender;
    uint256 public price;

    function buyQuote(uint256 amount) external view returns (uint256) {
        return amount / price;
    }

    function setWithOrCondition(uint256 newPrice, uint256 amount) external {
        require(msg.sender == owner || amount > 0, "no access");
        price = newPrice;
    }
}

// Regression: state variable declared in a base contract, protected entry point and
// arithmetic use declared in the derived contract.
contract EventsArithmeticBase {
    uint256 public baseRate;
}

contract EventsArithmeticDerived is EventsArithmeticBase {
    address public owner = msg.sender;

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    function increaseBaseRate(uint256 delta) external onlyOwner {
        baseRate += delta; //~WARN: `baseRate` is changed without an event but is used in arithmetic
    }

    function baseRateQuote(uint256 amount) external view returns (uint256) {
        return amount * baseRate;
    }
}

// Regression: an overridden base implementation is not an entry point of the derived
// contract, so its write must not be reported when the override emits an event.
abstract contract EventsArithmeticOverrideBase {
    uint256 public fee;
    address public owner = msg.sender;

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    function setFee(uint256 newFee) external virtual onlyOwner {
        fee = newFee;
    }

    function quote(uint256 amount) external view returns (uint256) {
        return amount * fee;
    }
}

contract EventsArithmeticOverrideDerived is EventsArithmeticOverrideBase {
    event FeeUpdated(uint256 fee);

    function setFee(uint256 newFee) external override onlyOwner {
        fee = newFee;
        emit FeeUpdated(newFee);
    }
}

// Regression: a `virtual` internal hook dispatches to the derived override, which emits.
abstract contract EventsArithmeticHookBase {
    uint256 public hookFee;
    address public owner = msg.sender;

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    function setHookFee(uint256 newFee) external onlyOwner {
        _setHookFee(newFee);
    }

    function _setHookFee(uint256 newFee) internal virtual {
        hookFee = newFee;
    }

    function hookQuote(uint256 amount) external view returns (uint256) {
        return amount * hookFee;
    }
}

contract EventsArithmeticHookDerived is EventsArithmeticHookBase {
    event HookFeeUpdated(uint256 fee);

    function _setHookFee(uint256 newFee) internal override {
        hookFee = newFee;
        emit HookFeeUpdated(newFee);
    }
}

// An unimplemented `virtual` hook resolves to the derived implementation, which is inspected.
abstract contract EventsArithmeticAbstractHookBase {
    uint256 public abstractFee;
    address public owner = msg.sender;

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    function setAbstractFee(uint256 newFee) external onlyOwner {
        _setAbstractFee(newFee);
    }

    function _setAbstractFee(uint256 newFee) internal virtual;

    function abstractQuote(uint256 amount) external view returns (uint256) {
        return amount * abstractFee;
    }
}

contract EventsArithmeticAbstractHookDerived is EventsArithmeticAbstractHookBase {
    function _setAbstractFee(uint256 newFee) internal override {
        abstractFee = newFee; //~WARN: `abstractFee` is changed without an event but is used in arithmetic
    }
}

// An inherited arithmetic expression follows a virtual return helper to the derived override.
abstract contract EventsArithmeticReturnHookBase {
    uint256 public returnHookFee;
    address public owner = msg.sender;

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    function setReturnHookFee(uint256 newFee) external onlyOwner {
        returnHookFee = newFee; //~WARN: `returnHookFee` is changed without an event but is used in arithmetic
    }

    function returnHookQuote(uint256 amount) external view returns (uint256) {
        return amount * _returnHookFee();
    }

    function _returnHookFee() internal view virtual returns (uint256);
}

contract EventsArithmeticReturnHookDerived is EventsArithmeticReturnHookBase {
    function _returnHookFee() internal view override returns (uint256) {
        return returnHookFee;
    }
}

// A concrete base inherited unchanged is reported once, not once per contract in the hierarchy.
contract EventsArithmeticConcreteBase {
    uint256 public concreteFee;
    address public owner = msg.sender;

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    function setConcreteFee(uint256 newFee) external onlyOwner {
        concreteFee = newFee; //~WARN: `concreteFee` is changed without an event but is used in arithmetic
    }

    function concreteQuote(uint256 amount) external view returns (uint256) {
        return amount * concreteFee;
    }
}

contract EventsArithmeticConcreteDerived is EventsArithmeticConcreteBase {}

contract ReproAccessNameCalleeResultIgnored {
    address public owner = msg.sender;
    uint256 public price;

    function buyQuote(uint256 amount) external view returns (uint256) {
        return amount / price;
    }

    function _checkOwner() internal view returns (bool) {
        return msg.sender == owner;
    }

    function setPrice(uint256 newPrice) external {
        _checkOwner();
        price = newPrice;
    }
}

// Qualified internal calls select the named base implementation instead of dispatching to an
// override. Cover writes, arithmetic use, and values returned into arithmetic for both `super`
// and explicit base qualification.
contract EventsArithmeticQualifiedBase {
    uint256 public superWriteRate;
    uint256 public baseWriteRate;
    uint256 public superArithmeticRate;
    uint256 public baseArithmeticRate;
    uint256 public superReturnRate;
    uint256 public baseReturnRate;

    function _setSuperWriteRate(uint256 newRate) internal virtual {
        superWriteRate = newRate; //~WARN: `superWriteRate` is changed without an event but is used in arithmetic
    }

    function _setBaseWriteRate(uint256 newRate) internal virtual {
        baseWriteRate = newRate; //~WARN: `baseWriteRate` is changed without an event but is used in arithmetic
    }

    function _superArithmeticQuote(uint256 amount) internal view virtual returns (uint256) {
        return amount * superArithmeticRate;
    }

    function _baseArithmeticQuote(uint256 amount) internal view virtual returns (uint256) {
        return amount * baseArithmeticRate;
    }

    function _superReturnRate() internal view virtual returns (uint256) {
        return superReturnRate;
    }

    function _baseReturnRate() internal view virtual returns (uint256) {
        return baseReturnRate;
    }
}

contract EventsArithmeticQualifiedDerived is EventsArithmeticQualifiedBase {
    address public owner = msg.sender;

    event RateUpdated(uint256 rate);

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    function setSuperWriteRate(uint256 newRate) external onlyOwner {
        super._setSuperWriteRate(newRate);
    }

    function setBaseWriteRate(uint256 newRate) external onlyOwner {
        EventsArithmeticQualifiedBase._setBaseWriteRate(newRate);
    }

    function setSuperArithmeticRate(uint256 newRate) external onlyOwner {
        superArithmeticRate = newRate; //~WARN: `superArithmeticRate` is changed without an event but is used in arithmetic
    }

    function setBaseArithmeticRate(uint256 newRate) external onlyOwner {
        baseArithmeticRate = newRate; //~WARN: `baseArithmeticRate` is changed without an event but is used in arithmetic
    }

    function setSuperReturnRate(uint256 newRate) external onlyOwner {
        superReturnRate = newRate; //~WARN: `superReturnRate` is changed without an event but is used in arithmetic
    }

    function setBaseReturnRate(uint256 newRate) external onlyOwner {
        baseReturnRate = newRate; //~WARN: `baseReturnRate` is changed without an event but is used in arithmetic
    }

    function superWriteQuote(uint256 amount) external view returns (uint256) {
        return amount * superWriteRate;
    }

    function baseWriteQuote(uint256 amount) external view returns (uint256) {
        return amount * baseWriteRate;
    }

    function superArithmeticQuote(uint256 amount) external view returns (uint256) {
        return super._superArithmeticQuote(amount);
    }

    function baseArithmeticQuote(uint256 amount) external view returns (uint256) {
        return EventsArithmeticQualifiedBase._baseArithmeticQuote(amount);
    }

    function superReturnQuote(uint256 amount) external view returns (uint256) {
        return amount * super._superReturnRate();
    }

    function baseReturnQuote(uint256 amount) external view returns (uint256) {
        return amount * EventsArithmeticQualifiedBase._baseReturnRate();
    }

    function _setSuperWriteRate(uint256 newRate) internal override {
        superWriteRate = newRate;
        emit RateUpdated(newRate);
    }

    function _setBaseWriteRate(uint256 newRate) internal override {
        baseWriteRate = newRate;
        emit RateUpdated(newRate);
    }

    function _superArithmeticQuote(uint256 amount) internal pure override returns (uint256) {
        return amount;
    }

    function _baseArithmeticQuote(uint256 amount) internal pure override returns (uint256) {
        return amount;
    }

    function _superReturnRate() internal pure override returns (uint256) {
        return 1;
    }

    function _baseReturnRate() internal pure override returns (uint256) {
        return 1;
    }
}
