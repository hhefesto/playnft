import axios from 'axios';
import { site } from "./ethereum_abi";
import Web3 from "web3";

// This function detects most providers injected at window.ethereum
import detectEthereumProvider from '@metamask/detect-provider';

const contractAddress = process.env.REACT_APP_CONTRACT_ADDRESS;
const apiHost = process.env.REACT_APP_API_HOST;

// --- section for simple promises that are initialized once, and then never changed --------------------
const web3 = new Promise ((resolve, reject) => {
    detectEthereumProvider().then((provider) => {
        if (provider) {
            resolve(new Web3(provider));
        } else {
            reject("No Ethereum wallet detected");
        }
    });
});

const siteContract = new Promise ((resolve, reject) => {
    web3.then((w3) => {
        resolve(new w3.eth.Contract(site, contractAddress));
    });
});

const userAccount = new Promise ((resolve, reject) => {
    detectEthereumProvider().then((ep) => {
        ep.request({ method: 'eth_requestAccounts' }).then((accounts) => {
            resolve(accounts[0]);
        });
    });
});

// --- section for Promise wrappers around web3 functions ----------------------
const getNumArt = function () {
    return new Promise((resolve, reject) => {
        siteContract.then((sc) => {
            sc.methods.getNumArt().call().then((r) => resolve(r[0]));
        });
    });
};

const getNumArtists = function () {
    return new Promise((resolve, reject) => {
        siteContract.then((sc) => {
            sc.methods.getNumArtist().call().then((r) => resolve(r[0]));
        });
    });
};

const getArt = function (artId) {
    return new Promise((resolve, reject) => {
        siteContract.then((sc) => {
            sc.methods.getArt(artId).call().then(resolve);
        });
    });
};

const getArtist = function (artistAddress) {
    return new Promise((resolve, reject) => {
        siteContract.then((sc) => {
            sc.methods.getArtist(artistAddress).call().then(resolve);
        });
    });
};

const getFeature = function (featureId) {
    return new Promise((resolve, reject) => {
        siteContract.then((sc) => {
            sc.methods.getFeature(featureId).call().then(resolve);
        });
    });
};

const getDisplayFeature = function (artId) {
    return new Promise((resolve, reject) => {
        siteContract.then((sc) => {
            sc.methods.getDisplayFeature(artId).call().then((r) => resolve(r[0]));
        });
    });
};

const getBid = function (bidId) {
    return new Promise((resolve, reject) => {
        siteContract.then((sc) => {
            sc.methods.getBid(bidId).call().then(resolve);
        });
    });
};

const addArtist = function (address) {
    return new Promise((resolve, reject) => {
        siteContract.then((sc) => {
            userAccount.then ((account) => {
                sc.methods.addArtist(address).estimateGas().then((gas) => {
                    try {
                        const method = sc.methods.addArtist(address);
                        const post = method.send({
                            from: account,
                            gas,
                        }).on('receipt', function(receipt){
                            resolve(receipt);
                        }).on('error', function(error, receipt) {
                            reject(error);
                        });
                    } catch (error) {
                        console.log(error);
                        alert(error);
                    }
                });
            });
        });
    });
};

const modifyArtistProfile = function (name, description) {
    return new Promise((resolve, reject) => {
        siteContract.then((sc) => {
            userAccount.then ((account) => {
                const method = sc.methods.modifyArtistProfile(name, description);
                method.estimateGas().then((gas) => {
                    method.send({
                        from: account,
                        gas,
                    }).on('error', function(error, receipt) {
                        reject(error);
                    }).on('receipt', function(receipt) {
                        resolve(receipt);
                    });
                });
            });
        });
    });
};

const startArtWithFeature = function () {
    return new Promise((resolve, reject) => {
        siteContract.then((sc) => {
            userAccount.then ((account) => {
                sc.methods.startArtWithFeature().estimateGas().then((gas) => {
                    sc.methods.startArtWithFeature().send({
                        from: account,
                        gas,
                    }).on('error', function(error, receipt) {
                        reject(error);
                    }).on('receipt', function(receipt) {
                        resolve(receipt);
                    });
                });
            });
        });
    });
};


const startFeature = function (artId, endTime) {
    return new Promise((resolve, reject) => {
        siteContract.then((sc) => {
            userAccount.then ((account) => {
                const method = sc.methods.startFeature(artId, endTime);
                method.estimateGas().then((gas) => {
                    method.send({
                        from: account,
                        gas,
                    }).on('error', function(error, receipt) {
                        reject(error);
                    }).on('receipt', function(receipt) {
                        resolve(receipt);
                    });
                });
            });
        });
    });
};

const makeBid = function (artId, request, amount) {
    return new Promise((resolve, reject) => {
        siteContract.then((sc) => {
            userAccount.then ((account) => {
                const method = sc.methods.makeBid(artId, request);
                method.estimateGas({value: amount}).then((gas) => {
                    method.send({
                        from: account,
                        gas,
                        value: amount
                    }).on('error', function(error, receipt) {
                        reject(error);
                    }).on('receipt', function(receipt) {
                        resolve(receipt);
                    });
                });
            });
        });
    });
};

const nextFeature = function (artId, endTime) {
    return new Promise((resolve, reject) => {
        siteContract.then((sc) => {
            userAccount.then ((account) => {
                const method = sc.methods.nextFeature(artId, endTime);
                method.estimateGas().then((gas) => {
                    method.send({
                        from: account,
                        gas,
                    }).on('error', function(error, receipt) {
                        reject(error);
                    }).on('receipt', function(receipt) {
                        resolve(receipt);
                    });
                });
            });
        });
    });
};

const finishArt = function (artId) {
    return new Promise((resolve, reject) => {
        siteContract.then((sc) => {
            userAccount.then ((account) => {
                const method = sc.methods.finishArt(artId);
                method.estimateGas().then((gas) => {
                    method.send({
                        from: account,
                        gas,
                    }).on('error', function(error, receipt) {
                        reject(error);
                    }).on('receipt', function(receipt) {
                        resolve(receipt);
                    });
                });
            });
        });
    });
};

const signFeatureImage = function (featureId, imageHash) {
    return new Promise((resolve, reject) => {
        web3.then ((w3) => {
            userAccount.then ((account) => {
                w3.currentProvider.sendAsync({
                    method: 'net_version',
                    params: [],
                    jsonrpc: "2.0"
                }, function (err, result) {
                    const netId = result.result;
                    const msgParams = JSON.stringify({types:{
                        EIP712Domain:[
                            {name:"name",type:"string"},
                            {name:"version",type:"string"},
                            {name:"chainId",type:"uint256"},
                            {name:"verifyingContract",type:"address"}
                        ],
                        Message:[
                            {name:"featureId",type:"uint64"},
                            {name:"imageHash",type:"string"}
                        ]
                    },
                        primaryType:"Message",
                        domain:{name:"Play NFT",
                                version:process.env.REACT_APP_VERSION,
                                chainId:process.env.REACT_APP_CHAIN_ID,
                                verifyingContract:process.env.REACT_APP_CONTRACT_ADDRESS
                                },
                        message:{featureId:featureId, imageHash:imageHash}
                    });

                    w3.currentProvider.sendAsync(
                        {
                            method: "eth_signTypedData_v3",
                            params: [account, msgParams],
                            from: account
                        },
                        function(err, result) {
                            if (err) {
                                reject(err);
                            } else {
                                resolve({message: msgParams, signature: result.result});
                            }
                        }
                    );
                });
            });
        });
    });
};

// --- section for component control methods ------------------------------------------

// returns solidity receipt for finishArt or nextFeature
const controlCompleteFeature = function (artId, featureId, completeArtwork, featureEndTime, imageData) {
    return new Promise((resolve, reject) => {
        web3.then ((w3) => {
            const imageHash = w3.utils.sha3(imageData);

            signFeatureImage(featureId, imageHash).then((signResult) => {
                const formData = new FormData();
                formData.append("imageData", imageData);
                formData.append("signedData", signResult.message);
                formData.append("signature", signResult.signature);
                formData.append("feature", featureId);

                axios.post(apiHost + "/upload-image", formData).then ((res) => {
                    if (res.data.status) {

                        if (completeArtwork) {
                            finishArt(artId).then((receipt) => {
                                resolve(receipt);
                            });

                        } else {
                            nextFeature(artId, featureEndTime).then((featureReceipt) => {
                                resolve(featureReceipt);
                            });
                        }
                    } else {
                        reject({error: "error uploading image", result:res});
                    }
                }).catch ((err) => {
                    reject({error: "problem signing/posting image", result:err});
                });
            });
        });
    });
};

// returns solidity receipt for startFeature
const controlStartArtWithFeature = function (featureEndTime, imageData) {
    return new Promise((resolve, reject) => {
        startArtWithFeature().then((receipt) => {

            const artId = receipt.events.ArtCreated.returnValues.artId;
            const featureId = receipt.events.FeatureCreated.returnValues.featureId;

            controlCompleteFeature(artId, featureId, false, featureEndTime, imageData).then(receipt => {
                resolve(receipt);
            }).catch (err => reject(err));
        });
    });
};

const makeWeb3LoginControls = function () {
	const installMetamask = 0;
	const loginMetamask = 1;
	const activeMetamask = 2;

	var state = installMetamask;

	const login = function (successCallback) {
		detectEthereumProvider().then(provider => {
		    provider.request({ method: 'eth_requestAccounts' })
			.then(_ => { state = activeMetamask; successCallback(); })
			.catch((error) => {
			});
		});
	};

	const handleClick = function (successCallback) {
		if (state === installMetamask) {
			window.open("https://metamask.io/", "_blank");
		} else if (state === loginMetamask) {
			login(successCallback);
		} else {
		    // shouldn't be possible
		    alert("handleClick: shouldn't be here");
		}
	};

	const getDisplay = function () {
		return state === installMetamask ? "Install Metamask"
            : state === loginMetamask ? "Login to Metamask"
            : "This message should be hidden";
	};

	const initComponent = function (successCallback) {
		web3.then(_ => { state = loginMetamask; successCallback(); });
	};

	const shouldHide = function () {
		return state === activeMetamask;
	};

	return {login: login, handleClick: handleClick, getDisplay: getDisplay, initComponent: initComponent
		, shouldHide: shouldHide };
};

const makeAdminControls = function () {

	const initComponent = function (setArtists) {
		siteContract.then((sc) => {
		    sc.methods.getNumArtist().call().then(na => setArtists(na));
		});
	};

	const handleSubmit = function (address, callback) {
		addArtist(address).then(receipt => callback(receipt));
	};

	return {initComponent: initComponent, handleSubmit: handleSubmit };
};

const makeArtistControls = function () {
	
	const initComponent = function (callback) {
		userAccount.then((account) => {
		    getArtist(account).then((artist) => {
			callback({artistName: artist[0], artistDescription: artist[1]});
		    });
		});
	};

	const profileSubmit = function (artistName, artistDescription, callback) {
		userAccount.then((account) => {
		    modifyArtistProfile(artistName, artistDescription).then((result) => {
			    callback(result);
		    });
		});
	};

	return { initComponent: initComponent, profileSubmit: profileSubmit };
};

const makeArtListingControls = function () {

	//const submitBid = function (
};

const getArtList = function () {
	return new Promise ((resolve, reject) => {
		getNumArt().then((na) => {
		    var artP = [];
		    for (var i = 1; i <= 10 && na - i >= 0; i++) {
			var artId = na - i;
			artP.push(getArtDisplay(artId));
		    }
		    Promise.all(artP).then(l => resolve(l));
		});
	});
};

// returns {artistName, imgUrl, timeText, bidAmount, featureRequest, makeBid, completeFeature}
const getArtDisplay = function (i) { // i is the artId
    return new Promise ((resolve, reject) => {
        getArt(i).then((art) => {
            const currentFeatureId = art[2];
            getArtist(art[0]).then((artist) => {
                getDisplayFeature(i).then((fid) => {
                    const endTimeCallback = (timeText, bidAmount, featureRequest) => {
                        const imgUrl = apiHost + "/" + fid + ".png";
			const completeFeature = function (comp, endTime, img) {
				return controlCompleteFeature(i, currentFeatureId, comp, endTime, img);
			};
                        resolve({artistName: artist[0], imgUrl: imgUrl, timeText: timeText
                                 , bidAmount: bidAmount, featureRequest: featureRequest
				, makeBid: function (req, amount) { return makeBid(i, req, amount); }
				, completeFeature: completeFeature

			});
                    };

                    if (art[1]) {
                        endTimeCallback("Artwork is complete", "", "");

                    } else if (currentFeatureId > -1) {
                        getFeature(currentFeatureId).then((feature) => {
                            const endTime = new Date(feature[1] * 1000);
                            const bidId = feature[3];
                            const timeText = "Bidding ending at " + endTime;
                            if (bidId > -1) {
                                getBid(bidId).then((bid) => {
                                    endTimeCallback(timeText, "Bid amount: " + bid[2], "Feature request: " + bid[3]);
                                });
                            } else {
                                endTimeCallback(timeText, "", "No bids yet");
                            }
                        });

                    } else {
                        endTimeCallback("Not open for bidding yet", "", "");
                    }
                });
            });
        });
    });
};

// --- section for web3 event listeners --------------------------------
const registerArtCreatedListener = function (callback) {
    siteContract.then((sc) => {
        sc.events.ArtCreated().on('data', event => {
            callback(event.returnValues.artId);
        });
    });
};

const registerFeatureCreatedListener = function (callback) {
    siteContract.then((sc) => {
        sc.events.FeatureCreated().on('data', event => {
            callback(event.returnValues.featureId);
        });
    });
};

export const api = {
	getArtList: getArtList,
	userAccount: userAccount,
	getNumArt: getNumArt,
	makeBid: makeBid,
	finishArt: finishArt,
	signFeatureImage: signFeatureImage,
	controlCompleteFeature: controlCompleteFeature,
	controlStartArtWithFeature: controlStartArtWithFeature,
	makeWeb3LoginControls: makeWeb3LoginControls,
	makeAdminControls: makeAdminControls,
	makeArtistControls: makeArtistControls,
	getArtDisplay: getArtDisplay,
	registerArtCreatedListener: registerArtCreatedListener,
	registerFeatureCreatedListener: registerFeatureCreatedListener,
};
