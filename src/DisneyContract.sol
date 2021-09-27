pragma solidity >=0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;

import "./ERC20Basic.sol";

contract DisneyContract {

    //  instancia del contrato token
    ERC20Basic private token;
    address payable public owner;

    constructor () public {
        token = new ERC20Basic(10000);
        owner = msg.sender;
    }

    struct Client {
        uint boughtTokens;
        string[] games;
    }

    mapping(address => Client) public clientMapping;

    //  funcion para establecer precio de token
    function tokenPrice(uint tokenNumber) internal pure returns (uint) {
        return tokenNumber * (1 ether);
    }

    //  funcion que valida cuantos tokens quedan
    function balanceOf() public view returns (uint){
        return token.balanceOf(address(this));
    }

    //  funcion para comprar token
    function buyToken(uint tokenNumber) public payable {
        uint token = tokenPrice(tokenNumber);
        //  se evalua el dinero que el cliente paga
        require(msg.value >= token, "Compra menos tokens o paga mas ehter");
        msg.sender.transfer(msg.value - token);
        uint balance = balanceOf();
        require(tokenNumber <= balance, "compra un numero menor de token");
        token.transfer(msg.sender, tokenNumber);
        clientMapping[msg.sender].boughtTokens += tokenNumber;
    }

    //  visualizar numero de tokens restantes
    function myTokens() public view returns (uint) {
        return token.balanceOf(msg.sender);
    }

    //  funcion para generar mas token
    function generateMoreToken(uint tokenNumber) public onlyExecute(msg.sender) {
        token.increaseTotalSupply(tokenNumber);
    }

    //  modificador para controlar funciones ejecutablespor Disney
    modifier onlyExecute(address addressOwner) {
        require(addressOwner == owner, "Denied, dont have permission for execute");
        _;
    }

    //  evento para disfrutar atraccion
    event enjoyGame(string, uint, address);
    //  evento para crear atraccion
    event newGame(string, uint);
    //  evento para dar de baja
    event deleteGame(string);
    event newFood(string, uint, bool);
    event deleteFood(string);
    event enjoyFood(string, uint, address);

    struct Game {
        string gameName;
        uint price;
        bool status;
    }

    struct Food {
        string foodName;
        uint foodPrice;
        bool foodStatus;
    }

    //  mapping para relacionar nombre de juego con la estructura juego
    mapping(string => Game) public gameMapping;
    mapping(string => Food) public foodMapping;
    string[] gameList;
    string[] foodList;

    //  mapping para relacionar identidad de cliente con historial
    mapping(address => string[]) historyGamesMapping;

    //  crear nuevos juegos para disney, solo ejecutable por disney
    function createNewGame(string memory gameName, uint price) public onlyExecute(msg.sender) {
        gameMapping[gameName] = Game(gameName, price, true);
        gameList.push(gameName);
        emit newGame(gameName, price);
    }

    //  dar de baja juego en disney
    function deleteExistingGame(string memory gameName) public onlyExecute(msg.sender) {
        //require(gameName != )
        gameMapping[gameName].status = false;
        emit deleteGame(gameName);
    }

    //  ver atracciones
    function getGames() public view returns (string[] memory) {
        return gameList;
    }

    //  funcion para subirse a un juego y pagar
    function getIntoGame(string memory gameName) public {
        uint tokenGame = gameMapping[gameName].price;
        require(gameMapping[gameName].status == true, "Not fund available game");
        require(tokenGame <= myTokens(), "Not have enough tokens to pay");
        token.transferDisney(msg.sender, tokenGame, address(this));
        //  almacenamiento en el historial de atracciones del cliente
        historyGamesMapping[msg.sender].push(gameName);
        emit enjoyGame(gameName, tokenGame, msg.sender);
    }

    //  funcion para ver el historial de un usuario disfrutado por un cliente
    function history() public view returns (string[] memory) {
        return historyGamesMapping[msg.sender];
    }

    //  funcion para que un cliente pueda devolver token
    function returnToken(uint tokensNumber) public payable {
        require(tokensNumber > 0, "You need to return a positive quantity of token");
        require(tokensNumber <= myTokens(), "dont have necesary token to return");
        token.transferDisney(msg.sender, tokensNumber, address(this));
        msg.sender.transfer(tokenPrice(tokensNumber));
    }

    //  funcion para crear menus de comida
    function createNewFood(string memory foodName, uint foodPrice) public onlyExecute(msg.sender) {
        foodMapping[foodName] = Food(foodName, foodPrice, true);
        foodList.push(foodName);
        emit newFood(foodName, foodPrice, true);
    }

    function deleteExistingFood(string memory foodName) public onlyExecute(msg.sender) {
        //require(gameName != )
        foodMapping[foodName].status = false;
        emit deleteGame(foodName);
    }

    function getFood() public view returns (string[] memory) {
        return foodList;
    }

    function buyFood(string memory foodName) public {
        uint tokenFood = foodMapping[foodName].price;
        require(foodMapping[foodName].foodStatus == true, "Not fund available food");
        require(tokenFood <= myTokens(), "Not have enough tokens to pay");
        token.transferDisney(msg.sender, tokenFood, address(this));
        //  almacenamiento en el historial de comidas del cliente
        historyGamesMapping[msg.sender].push(foodName);
        emit enjoyFood(foodName, tokenFood, msg.sender);
    }
}
