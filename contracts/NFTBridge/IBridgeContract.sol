interface IBSCBridge {
    function mintToken(address token, uint256 tokenId) external returns(bool);
}
interface IEthereumBridge {
    function transferNFT(address token, uint256 tokenId) external;
}