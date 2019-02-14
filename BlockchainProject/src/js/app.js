let appInstance;

App = {
  web3Provider: null,
  contracts: {},
  account: "0x0",

  init: function() {
    return App.initWeb3();
  },

  initWeb3: function() {
    if (typeof web3 !== "undefined") {
      // If a web3 instance is already provided by Meta Mask.
      App.web3Provider = web3.currentProvider;
      web3 = new Web3(web3.currentProvider);
    } else {
      // Specify default instance if no web3 instance provided
      App.web3Provider = new Web3.providers.HttpProvider(
        "http://localhost:7545"
      );
      web3 = new Web3(App.web3Provider);
    }
    return App.initContract();
  },

  initContract: function() {
    $.getJSON("Project.json", function(project) {
      // Instantiate a new truffle contract from the artifact
      App.contracts.Project = TruffleContract(project);
      // Connect provider to interact with contract
      App.contracts.Project.setProvider(App.web3Provider);

      return App.render();
    });
  },

  register: function() {
    //var candidateId = $('#candidatesSelect').val();
    console.log("entered");

    // App.contracts.Project.deployed()
    //   .then(function(instance) {
    //     return instance.registeredAddr(App.account);
    //
    //   })
    appInstance
      .registeredAddr(App.account)
      .then(function(res) {
        // Wait for votes to update
        if (res == "doctor") {
          console.log(res);
          console.log("its true");
          //$("#accountAddress").html("You are doctor");
          $("#accountAddress").html('<a href="doctor.html"></a>');
          document.querySelector("a").click();
        } else {
          console.log(res);
          console.log("in false");
          //$("#accountAddress").html("You are contract");
          $("#accountAddress").html('<a href="welcome.html"></a>');
          document.querySelector("a").click();
        }
        $("#loader").hide();
        $("#content").show();
      })
      .catch(function(err) {
        console.error(err);
      });
    //vinu
  },

  AddedRecord: function() {
    //var candidateId = $('#candidatesSelect').val();
    console.log("entered");

    //  var id = $("#id").val();
    var name = $("#usr").val();
    var age = $("#age").val();
    var weight = $("#weight").val();
    var gender = $("#gender").val();
    var symptoms = $("#symptoms").val();

    console.log(name, age, weight, gender, symptoms);

    appInstance
      .addRecord(name, age, weight, gender, symptoms, {
        from: App.account,
        gas: 700000
      })

      // App.contracts.Project.deployed()
      //   .then(function(instance) {
      //     var id = $("#id").value;
      //     var name = $("#usr").value;
      //     var age = $("#age").value;
      //     var weight = $("#weight").value;
      //     var gender = $("#gender").value;
      //     var symptoms = $("#symptoms").value;
      //
      //     return instance.addRecord(name, age, weight, gender, symptoms, {
      //       from: App.account,
      //       gas: 700000
      //     });
      //   })
      .then(id => {
        // Wait for votes to update
        console.log("success transfer");
        //  console.log(instance.globalRid);

        appInstance
          .globalRid({
            from: App.account,
            gas: 700000
          })
          .then(id => {
            console.log("id = ", id.toNumber());
          });

        $("#loader").hide();
        $("#content").hide();
        $("#idDisplay").html("19");
        $("#showId").show();
        // $("#idDisplay").html("id.toNumber() - 1");
        // $("#b1").html('<a href="idpage.html"></a>');
        // document.querySelector("a").click();
      });
    // .catch(function(err) {
    //   console.error(err);
    // });
    //vinu
  },

  sendMoney: function() {
    //var candidateId = $('#candidatesSelect').val();
    console.log("entered");
    // App.contracts.Project.deployed()
    //   .then(function(instance) {
    //     var amount = 50;
    //     return instance.sendRecordAndDepositFee(101, {
    //       from: App.account,
    //       gas: 700000,
    //       value: 50
    //     });
    //   })
    appInstance
      .sendRecordAndDepositFee(1, {
        from: App.account,
        to: "0x9480e9e19784897c5df8972243c5043321073c4e",
        gas: 700000,
        value: web3.toWei(50, "ether")
      })
      .then(() => {
        // Wait for votes to update
        console.log("success transfer send money");
        $("#loader").hide();
        $("#content").show();
        $("#content").hide();
        $("#showDep").show();
      })
      .catch(function(err) {
        console.error(err);
      });
    //vinu
  },

  SendingFeedback: function() {
    //var candidateId = $('#candidatesSelect').val();
    console.log("entered");

    //  var id = $("#id").val();
    var usid = $("#usid").val();
    var feedback = $("#feedback").val();

    //  console.log(name, age, weight, gender, symptoms);

    appInstance
      .sendFeedback(usid, feedback, {
        from: App.account,
        gas: 700000
      })
      .then(id => {
        // Wait for votes to update
        console.log("success feedback");
        //  console.log(instance.globalRid);

        $("#loader").hide();
        $("#content").hide();
        $("#showfeedback").show();

        appInstance
          .releaseMoneyToDoctor(usid, {
            from: App.account,
            gas: 700000
          })
          .then(id => {
            // Wait for votes to update
            console.log("success feedback");
            //  console.log(instance.globalRid);

            $("#loader").hide();
            $("#content").hide();
            $("#showfeedback").show();
          });
      });
  },

  render: function() {
    var projInstance;
    var loader = $("#loader");
    var content = $("#content");

    loader.show();
    content.hide();

    // Load account data
    web3.eth.getCoinbase(function(err, account) {
      if (err == null) {
        console.log(account);
        App.account = account;
        //$("#accountAddress").html("Contract Account: " + account);
      }
    });

    // Load contract data
    App.contracts.Project.deployed().then(function(instance) {
      projInstance = instance;
      appInstance = instance;
      loader.hide();
      content.show();
    });
  }
};

$(function() {
  $(window).load(function() {
    App.init();
  });
});
