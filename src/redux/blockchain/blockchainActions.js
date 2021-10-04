import Web3 from "web3";
import LipToken from "../../contracts/LipToken.json";

const connectRequest = () => {
    return {
        type: "CONNECTION_REQUEST",
    };
};

const connectSuccess = (payload) => {
    return {
        type: "CONNECTION_SUCCESS",
        payload: payload,
    };
};

const connectFailed = (payload) => {
    return {
        type: "CONNECTION_FAILED",
        payload: payload,
    };
};

const updateAccountRequest = (payload) => {
    return {
        type: "UPDATE_ACCOUNT",
        payload: payload,
    };
};

export const connect = () => {
    return async (dispatch) => {
        dispatch(connectRequest());
        // If browser can conect to blockchain
        if (window.ethereum) { 
            let web3 = new Web3(window.ethereum);
            try {
                const accounts = await window.ethereum.request({ // Try get users accounts
                    method: "eth_accounts",
                });
                console.log("Account: ", accounts[0]);
                const networkId = await window.ethereum.request({ // Try get network id
                    method: "net_version",
                });
                console.log("network Id: ", networkId);
                const lipTokenNetworkData = await LipToken.networks[networkId];// Find LipToken network id
                if (lipTokenNetworkData) { // If there is a liptoken network
                    const lipToken = new web3.eth.Contract( // Get lipToken contract
                        LipToken.abi, // Using abi and
                        lipTokenNetworkData.address // contract address
                    );
                    dispatch( // Dispatch a successful connection after we connect to the contract
                        connectSuccess({
                            account: accounts[0],
                            lipToken: lipToken,
                            web3: web3,
                        })
                    );
                    // Add Listeners
                    window.ethereum.on("accountsChanged", (accounts) => { // When user changes accounts
                        dispatch(updateAccount(accounts[0])); // Update accounts function
                    });
                    window.ethereum.on("chainChanged", () => { // When user changes network 
                        window.location.reload(); // Reload the window
                    });
                } else {
                    dispatch(connectFailed("Change network to Polygon."));
                }
            } catch (err) {
                dispatch(connectFailed("Something went wrong."));
            }
        } else {
            dispatch(connectFailed("Install Metamask."));
        }
    };
};

export const updateAccount = (account) => {
    return async (dispatch) => {
        dispatch(updateAccountRequest({ account: account }));
        // dispatch(fetchData(account));
    };
};