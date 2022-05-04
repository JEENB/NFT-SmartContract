// SPDX-License-Identifier: MIT

// This contract is like a database of Alumns. The database has name email and pub_key associated wita a alumn. 
// Assumption: Every alumn has a public key for their EOA. 
// This database (contract is maintiained by the university so only the owner of the contract will be able to addalumn. 
// This database will be used when transferifng ownership of a AshokaNFT. 

// Add these as alumns: The addresses are remix built in
// jenish, jenish@ashoka.edu.in, 0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB
// jenish1, jenish1@ashoka.edu.in, 0x583031D1113aD414F02576BD6afaBfb302140225
// jenish2, jenish2@ashoka.edu.in, 0xdD870fA1b7C4700F2BD7f44238821C26f7392148

pragma solidity ^0.8.4;

contract ashokaAlumn{
    address owner;

    constructor() {
        owner = msg.sender;
    }

    modifier ownerOnly {
        require(msg.sender == owner, "Only the owner can addAlumn");
        _;
    }

    // Alumn struct stored name, email and public key associated to the alumn. 
    struct Alumn{
        string name;
        string email;
        address pub_key;
    }

    Alumn []alumns;

    function addAlumn(string memory name, string memory email, address pub_key) public ownerOnly{
        Alumn memory e = Alumn(name, email, pub_key); 
        alumns.push(e);
    }

    function isAlumn(address pub_key) public view returns(bool){
        uint i;
        for(i=0; i<alumns.length; i++){
            Alumn memory e = alumns[i];
            if(pub_key == e.pub_key)
            {
                return true;
            }
        }
        return false;
    }

}