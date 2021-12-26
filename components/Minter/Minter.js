import { useState } from "react";
import styles from "./Minter.module.scss";
import Card from "@mui/material/Card";
import CardContent from "@mui/material/CardContent";
import AccountBalanceWalletIcon from "@mui/icons-material/AccountBalanceWallet";
import Typography from "@mui/material/Typography";
import { ethers, Contract } from 'ethers';
import abi from './mekicat.json'

const Minter = () => {
  const [provider, setProvider] = useState(undefined);
  const [nft, setNft] = useState(undefined);
  const [isConnected, setConnected] = useState(false);
  const [quantidade, setQuantidade] = useState("1");
  const [address, setAddress] = useState(undefined);
  const [minted, setMinted] = useState(false);

  const init = async () => {
    console.log('entrou');
    if (window.ethereum) {
      try {
        // check if the chain to connect to is installed
        await window.ethereum.request({
          method: 'wallet_switchEthereumChain',
          params: [{ chainId: '0x4' }], // switch to Rinkeby
        });
        await window.ethereum.enable();
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        const signer = provider.getSigner();
        const account = await signer.getAddress();
        const nft = new Contract(
          '0xA83773088125f02810076b5417d9De6919A9174A',
          abi,
          signer
        );
        setProvider(provider);
        setNft(nft);
        //console.log(provider);
        //console.log(nft);
        setConnected(true);
        setAddress(account);
      } catch (error) {
        // This error code indicates that the chain has not been added to MetaMask
        // if it is not, then install it into the user MetaMask
        if (error.code === 4902) {
          try {
            await window.ethereum.request({
              method: 'wallet_addEthereumChain',
              params: [
                {
                  chainId: '0x4',
                  rpcUrl: 'https://eth-rinkeby.alchemyapi.io/v2/AjvQfwEEeSPY_QF5LRMRbQzn99qeogCn',
                },
              ],
            });
          } catch (addError) {
            console.error(addError);
          }
        }
        console.error(error);
      }//FIM CATCH
    } else {
      // if no window.ethereum then MetaMask is not installed
      alert('MetaMask is not installed. Please consider installing it: https://metamask.io/download.html');
    }
  };

  const mint = async () => {
    setMinted(false);
    console.log(provider);
    console.log(nft);

    //TX Mint
    try {
      console.log("Executing Minting...");
      // const user = ethereum.selectedAddress();
      console.log(nft)
      console.log(provider)
      const signer = provider.getSigner();
      console.log(signer)

    
      const tx1 = await nft.mintByUsers(quantidade)
      tx1.wait();
      console.log(tx1)
    



      /*
      console.log('passou')
      const tx3 = await signer.sendTransaction({
        data: nft.mintByUsers(quantidade).encodeABI(),
        value: '0.1',
      })
      tx3.wait();
      console.log(tx3)
      */
      

    
      console.log("Minting DONE");
      setMinted(true);
    } catch (error) {
      console.log('That minting did not go well.')
    }
  }

  return (

    <div className={styles.minter}>
      <h2 className={styles._title}>Public Sale Is Live :</h2>
      {!isConnected && (
        <h2
          className={styles._title}
          style={{ color: "#f2f850", marginTop: "20px" }}
        >
          New to Metamask?
        </h2>
      )}

      {isConnected ? (
        <Card className={styles._card}>
          <CardContent className={styles._card_content}>

            <div className="Minter">
              <h1 id="title">Minter</h1>
              <p>
                Enter quantity you want to mint
              </p>

              <form>
                <h2>Quantity</h2>
                <input
                  type="number"
                  max="10"
                  min="1"
                  onChange={(event) => setQuantidade(event.target.value)}
                />
                <button
                  type='button'
                  onClick={() => mint()}
                >
                  Mint
                </button>
              </form>
              <hr />
              {minted ? (
                <a href="https://testnets.opensea.io/collection/mekicats-test-vjlfmsxqh2">LINK TO OPENSEA</a>
              ) : (
                <div>Awaiting to mint...</div>
              )}
            </div>
          </CardContent>
        </Card>
      ) : (
        <Card className={styles._card}>
          <CardContent className={styles._card_content}>
            <AccountBalanceWalletIcon style={{ fontSize: "50px" }} />
            <Typography variant="h6" color="inherit">
              Yes, let&apos;s get set up!
            </Typography>
            <Typography variant="subtitle2" color="inherit" component="p">
              This will create a new wallet and seed phrase!
            </Typography>
            <button className={styles.wallet_btn} onClick={() => init()}>
              connect a wallet
            </button>
          </CardContent>
        </Card>
      )}
    </div>
  );
};

export default Minter;
