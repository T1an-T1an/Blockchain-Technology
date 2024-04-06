// SPDX-License-Identifier: MIT
/*
Assignment 05 – Supply Chain Product Payment Management
Name: Jingda Yang
Date: 04/01/2024
*/

// Set solidity version
pragma solidity ^0.8.13;

// Create this new contract: ProductManager
contract ProductManager {
    //Enumerated list for supply chain steps, creation, payment, shipment, and delivery.
    enum SupplyChainSteps { Created, Paid, Shipped, Delivered }

    //Define the attributes of a product within the supply chain.
    //Struct with Product_Details(steps, identifier, and price)
    struct S_Product {
        string _identifier;         //_identifier: A unique string identifier for the product.
        uint _priceInWei;           //_priceInWei: The price of the product in Wei
        uint _leadtime;             //_leadtime: The estimated time for the product to be delivered.
        ProductManager.SupplyChainSteps _step;     //_step: The current stage of the product in the supply chain
    }

    //A mapping from Product_Details to products.
    // Mapping from a uint (unsigned integer) to S_Product structs. This mapping stores all the products
    mapping(uint => S_Product) public products;

    //An auto-incrementing index: Assign a unique index to each product in the mapping.
    uint index;

    //An event trigger that creates triggers for all the four steps
    event SupplyChainStep(uint _productIndex, uint _step);

    // 1. Create Item Function: The function below creates a product and sets it for delivery
    function createProduct(string memory _identifier, uint _priceInWei, uint _leadtime) public {
        // _identifier: Assign the unique identifier to the product at the current index
        products[index]._identifier = _identifier;

        //_priceInWei: Set the price of the product in Wei
        products[index]._priceInWei = _priceInWei;

        // _leadtime: Set the leadtime for the product, representing how long it will take to deliver the product
        products[index]._leadtime = _leadtime;

        // Initialize the product's status in the supply chain to 'Created'
        products[index]._step = SupplyChainSteps.Created;

        // Emit an event to log the creation of the product.
        emit SupplyChainStep(index, uint(products[index]._step));

        // Increment the index to prepare for the next product creation
        index++;
    }

    // 2. Trigger Payment Function: The function below checks for the payment and updates the flag to "Paid"
    function initiatePayment(uint _index) public payable {
        // Check if the full payment is received
        require(products[_index]._priceInWei <= msg.value, "Insufficient payment");
        
        // Check if the state of product is Created
        require(products[_index]._step == SupplyChainSteps.Created, "Product already Shipped");

        // Set item step to paid
        products[_index]._step = SupplyChainSteps.Paid;
        // Emit the transaction
        emit SupplyChainStep(_index, uint(products[_index]._step));
    }

    // 3. Trigger Shipment Function: The function below Ships the product and updates the flag to 'Shipped'
    function initiateShipment(uint _index) public {
        // Set item step to Shipped
        products[_index]._step = SupplyChainSteps.Paid;
        
        // Check if the state of product is Paid
        require(products[_index]._step == SupplyChainSteps.Paid, "Product already in Transit");

        // Set the leadtime
        products[_index]._leadtime = block.timestamp + 5 minutes;

        // Emit the transaction
        emit SupplyChainStep(_index, uint(products[_index]._step));
    }

    // 4. Trigger Delivery Function: The function below delivers the product and updates the flag to 'Delivered'
    function closeDelivery(uint _index) public {
        /* Check if the leadtime has elapsed
        Create a delay of 5 days (for the assignment, set this 5 mins), delay was set in the previous function.
        If delay <=5 then display “product in transit” else, display delivered
        */
        require(products[_index]._leadtime <= block.timestamp, "Product still in Transit");
        
        // Set item step to Delivered
        products[_index]._step = SupplyChainSteps.Delivered;
        
        // Emit the transaction
        emit SupplyChainStep(_index, uint(products[_index]._step));
    }
}
