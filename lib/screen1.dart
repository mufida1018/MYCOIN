import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:pkcoin/slider.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:web3dart/web3dart.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late Client httpClient ;
  late Web3Client ethClient ;
  final myAddress = '0x9Ed53C4759fa98776ab9e2F3E3FCdAF4D87EfFB2';
  bool data = false ;
  int myAmount=0;
  var myData;

 @override
  void initState() {
    super.initState();
    httpClient = Client();
    ethClient = Web3Client("https://rinkeby.infura.io/v3/fff31b4452a94682926f9b09546e1f4d", httpClient);
    getBalance(myAddress);
  }


  Future<DeployedContract> loadContracts()async{
   String abi = await rootBundle.loadString("assets/abi.json");
   String contractAddress = "0x9A3803Ec0e6b42dDAC714581D7183907cdb26960";
   final contract = DeployedContract(ContractAbi.fromJson(abi, "PKcoin"), EthereumAddress.fromHex(contractAddress));
   return contract ;
  }

  Future<List<dynamic>> query(String functionName , List<dynamic> args)async{
   final contract = await loadContracts();
   final ethFunction = contract.function(functionName);
   final result = await ethClient.call(contract: contract, function: ethFunction, params: args);
   return result ;
  }

  Future<void> getBalance(String targetAddress)async{
   // EthereumAddress address = EthereumAddress.fromHex(targetAddress);
   List<dynamic> result = await query("getBalance", []);
   myData = result[0];
   data = true;
   setState(() {});
  }

  Future<String> sendCoin() async {
   var bigAmount = BigInt.from(myAmount);
   var response = await submit("depositeBalance", [bigAmount]);
   print("Deposite");
   return response ;
  }


  Future<String> submit (String functionName , List<dynamic> args) async {
    EthPrivateKey credentials = EthPrivateKey.fromHex("4c74099eabb30549ae3455ebb1e522186dbbb02b0a0fc1dbe45f8caba63b3ab1");
    DeployedContract contract = await loadContracts();
   final ethFunction = contract.function(functionName);
   final results = await ethClient.sendTransaction(credentials,
       Transaction.callContract(contract: contract, function: ethFunction, parameters: args),
     fetchChainIdFromNetworkId: true,
   );
   return results ;
  }

  Future<String> withdrawCoin() async {
    var bigAmount = BigInt.from(myAmount);
    var response = await submit("depositeBalance", [bigAmount]);
    print("withdraw");
    return response ;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
         body: ZStack([
           VxBox().blue500.size(context.screenWidth, context.percentHeight * 30).make(),
           VStack([
             (
                 context.percentHeight * 10).heightBox,
                 "\$MYCOIN".text.xl4.white.bold.center.makeCentered().py16(),
             (context.percentHeight * 5).heightBox,
             VxBox(
               child: VStack([
                 "Balance".text.gray700.xl2.semiBold.makeCentered(),
                 10.heightBox,
                  data?"\$${myData}".text.bold.xl5.makeCentered().shimmer():CircularProgressIndicator().centered(),
               ])
             ).p16.white.size(context.screenWidth, context.percentHeight * 18).rounded.shadowXl.make().p16(),
             30.heightBox,
             SliderWidget(
                min: 0,
                max: 100,
                finalVal: (value){
                  myAmount= (value * 100).round() ;
                  print(myAmount);
                },
             ).centered(),
             HStack([
               ElevatedButton.icon(  onPressed: () => getBalance(myAddress),
                   icon: Icon(Icons.refresh),
                   label:"Refresh".text.white.make()).h(40),

               ElevatedButton.icon(  onPressed: () => sendCoin(),
                   icon: Icon(Icons.call_made_outlined),
                   label:"Deposit".text.white.make(),
                   style: ElevatedButton.styleFrom(
                     primary: Colors.green,
                   )).h(40),

               ElevatedButton.icon(  onPressed: () => withdrawCoin(),
                   icon: Icon(Icons.call_received_outlined),
                   label:"WithDraw".text.white.make(),
                   style: ElevatedButton.styleFrom(
                     primary: Colors.deepOrangeAccent,
                   )).h(40),
             ],
               alignment: MainAxisAlignment.spaceAround,
               axisSize: MainAxisSize.max,
             ).p16(),
           ]),
         ]
         ),
    );
  }
}
