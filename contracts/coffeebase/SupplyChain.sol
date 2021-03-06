pragma solidity ^0.4.24;
// Define a contract 'Supplychain'

contract SupplyChain {

    /** 
    * Variables
    */
    // Define 'owner'
    address owner;

    // Define a variable called 'sku' for Stock Keeping Unit (SKU)
    uint  sku; //Stock Keeping Unit (SKU)

    // Define a public mapping 'items' that maps the UPC to an Item.
    mapping (uint => Item) items;
    

    /**
    * Events: 
    */
    // Define 11 events with the same 8 state values and accept 'upc' as input argument
    event Harvested(uint upc);  //0
    event Processed(uint upc);  //1
    event Packed(uint upc); //2
    event ForSale(uint upc); //3
    event Sold(uint upc); //4

    event ForTransfer(uint upc) //5
    event Collected(uint upc); //6
    event Shipped(uint upc); //7

    event Received(uint upc); //8
    event AddedToStock(uint upc); //9
    
    event Bought(uint upc); //10

    /**
    * State : Define enum 'State' with the following values:
    */
    enum State 
    { 
        Harvested,  // 0
        Processed,  // 1
        Packed,     // 2

        ForSale,    // 3
        Sold,       // 4

        ForTransfer, // 5
        Collected, // 6
        Shipped, // 7

        Received,   // 8
        AddedToStock, // 9
 
        Bought   // 10
    }

State constant defaultState = State.Harvested;

/**
* Item : Define a struct 'Item' with the following fields:
*/
struct Item { 
    uint    sku;  //(1) Stock Keeping Unit (SKU)
    uint    upc; //(2) Universal Product Code (UPC), generated by the Farmer, goes on the package, can be verified by the Consumer
    address ownerID;  //(3) Metamask-Ethereum address of the current owner as the product moves through 8 stages
    address idFarmer; //(4) Metamask-Ethereum address of the Farmer
    uint    price; //(5) Product Price
    State   itemState;  //(6) Product State as represented in the enum above
    address idDistributor;  //(7) Metamask-Ethereum address of the Distributor
    address idRetailer; //(8) Metamask-Ethereum address of the Retailer
    address idConsumer; //(9) Metamask-Ethereum address of the Consumer
}

/**
* Modifiers:
*/
modifier onlyOwner() {
    require(msg.sender == owner);
    _;
}
modifier paidEnough(uint _price){
    require(msg.value >= _price); 
    _;
}
modifier harvested(uint _upc){
    require(items[_upc].itemState == State.Harvested);
    _;
}
modifier processed(uint _upc){
    require(items[_upc].itemState == State.Processed);
    _;
}
modifier packed(uint _upc){
    require(items[_upc].itemState == State.Packed);
    _;
}
modifier forSale(uint _upc){
    require(items[_upc].itemState == State.ForSale);
    _;
}
modifier sold(uint _upc){
    require(items[_upc].itemState == State.Sold);
    _;
}
modifier forTransfer(uint _upc){
    require(items[_upc].itemState == State.ForTransfer);
    _;
}
modifier collected(uint _upc){
    require(items[_upc].itemState == State.Collected);
    _;
}
modifier shipped(uint _upc){
    require(items[_upc].itemState == State.Shipped);
    _;
}
modifier received(uint _upc){
    require(items[_upc].itemState == State.Received);
    _;
}
modifier addedToStock(uint _upc){
    require(items[_upc].itemState == State.AddedToStock);
    _;
}
 
modifier bought(uint _upc){
    require(items[_upc].itemState == State.Bought);
    _;
}

/** 
* Constructor:
* In the constructor set 'owner' to the address that instantiated the contract
    and set 'sku' to 1
    and set 'upc' to 1
*/

constructor() public payable {
    owner = msg.sender;
    sku = 1;
    upc = 1;
}
 
 
// Define a function 'harvestItem' that allows a farmer to mark an item 'Harvested'
function harvestItem(uint _upc,address _idFarmer) public 
{
    // Add the new item as part of Harvest 
    items[_upc]=Item({ sku:sku,upc:_upc,ownerID:owner,idFarmer:_idFarmer,price:0,itemState:State.Harvested,idDistributor:0,idRetailer:0,idConsumer:0});

    // Increment sku
    sku = sku + 1;
    // Emit the appropriate event
    emit Harvested(_upc);

}

// Define a function 'processtItem' that allows a farmer to mark an item 'Processed'
function processItem(uint _upc) harvested(_upc) public 
{
    // Update the appropriate fields
    items[_upc].itemState = State.Processed;

    // Emit the appropriate event
    emit Processed(_upc);
}

// Define a function 'packItem' that allows a farmer to mark an item 'Packed'
function packItem(uint _upc) processed(_upc) onlyOwner() public 
{
    // Update the appropriate fields
    items[_upc].itemState = State.Packed;

    // Emit the appropriate event
    emit Packed(_upc);

}

// Define a function 'sellItem' that allows a farmer to mark an item 'ForSale'
function sellItem(uint _upc, uint _price) packed(_upc) public 
{
    // Update the appropriate fields
    items[_upc].itemState = State.ForSale;
    items[_upc].productPrice = _price;
    // Emit the appropriate event
    emit ForSale(_upc);

}

// Define a function 'buyItem' that allows the disributor to mark an item 'Sold'
// Use the above defined modifiers to check if the item is available for sale, if the buyer has paid enough, 
// and any excess ether sent is refunded back to the buyer
function buyItem(uint _upc,uint _price) forSale(_upc) paidEnough(_price) public payable 
{
    // Update the appropriate fields - ownerID, distributorID, itemState
    items[_upc].ownerID = msg.sender;
    items[_upc].distributorID = msg.sender;
    items[_upc].itemState = State.Sold;

    // Transfer money to farmer
    items[_upc].idFarmer.transfer(_price);

    // emit the appropriate event
    emit Sold(_upc);
}

 
 
// Define a function 'fetchItemBufferOne' that fetches the data
function fetchItem(uint _upc) public view returns 
(
uint    _sku,//0
uint    _upc,//1
address _ownerID,//2
address _idFarmer,//3
uint  _price,//4
address  _idDistributor,//5
address _idRetailer,//6
address _idConsumer//7
) 
{
    // Assign values to the 8 parameters
    _sku = items[_upc].sku; //0
    _upc = items[_upc].upc; //1
    _ownerID = items[_upc].ownerID; //2
    _idFarmer = items[_upc]._idFarmer; //3
    _price = items[_upc].price; //4
    _idDistributor = items[_upc].idDistributor; //5
    _idRetailer = items[_upc].idRetailer; //6
    _idConsumer = items[_upc].idConsumer; //7

return 
(
_sku, //0
_upc, //1
_ownerID, //2
_idFarmer, //3
_price, //4
_idDistributor, //5
_idRetailer, //6
_idConsumer //7
);
}
  
}
