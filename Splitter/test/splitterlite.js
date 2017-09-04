var SplitterLite = artifacts.require("./SplitterLite.sol");

contract('SplitterLite', function(accounts) {
  var contract;

  var u = {
    alice: accounts[0],
    bob: accounts[1],
    carol: accounts[2],
    david: accounts[3],
    emma: accounts[4]
  };

  // in wei
  var testValueEven = 6;
  var testValueOdd = 7;

  beforeEach(function() {
    return SplitterLite.new({from: u.alice})
    .then(function(instance) {
      contract = instance;
    });
  });

  it("Alice splits an even amount of wei between Bob and Carol", function () {
    var fromBalBefore = web3.eth.getBalance(u.alice);
    var to1BalBefore = web3.eth.getBalance(u.bob);
    var to2BalBefore = web3.eth.getBalance(u.carol);

    // compute expected balances
    var value = testValueEven;
    var valueTo1 = Math.floor(value / 2);
    var valueTo2 = value - valueTo1 + 1;

    return contract.split(
      u.bob,
      u.carol,
      {from: u.alice, value: value})
    .then(function(txn) {
      // check that split() didn't throw by running out of gas
      var tx = web3.eth.getTransaction(txn.tx);
      var txr = txn.receipt;
      assert.notStrictEqual(txr.gasUsed, tx.gas, "All gas was used up, split() threw an exception.");

      // check Alice's balance
      // note that this simple check works because her account is the etherbase,
      // i.e., transaction fees are a wash
      assert.strictEqual(web3.eth.getBalance(u.alice).plus(value).toString(10), fromBalBefore.toString(10), "Alice's expected balance doesn't match");

      return contract.balances(u.bob);
    })
    .then(function(to1BalAfter) {
      assert.equal(to1BalAfter.toString(10), to1BalBefore.plus(valueTo1).toString(10), "Bob's expected balance doesn't match");

      return contract.balances(u.carol);
    })
    .then(function(to2BalAfter) {
      assert.strictEqual(to2BalAfter.toString(10), to2BalBefore.plus(valueTo2).toString(10), "Carol's expected balance doesn't match");

      assert.strictEqual(1, 2, "Something is broken");
    });
  });
});