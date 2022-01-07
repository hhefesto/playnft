import React, { useState } from "react";
import logo from './logo.svg';
import './App.css';

import * from './backend/ethereum';

class MetaMaskButton extends React.Component {
    constructor(props) {
        super(props);

        this.handleClick = this.handleClick.bind(this);
        this.getDisplay = this.getDisplay.bind(this);
        this.login = this.login.bind(this);

        this.state = {
            value: installMetamask,
        };

        var t = this;
        var cb = function () {
            t.setState({value: loginMetamask});
        };
        web3.then(cb);
    }

    handleClick () {
        if (this.state.value === installMetamask) {
            window.open(
              "https://metamask.io/",
              "_blank"
            );
        } else if (this.state.value === loginMetamask) {
            this.login();
        } else {
            // shouldn't be possible
            alert("handleClick: shouldn't be here");
        }
    }

    async login () {
        const t = this;
        try {
            const provider = await detectEthereumProvider();
            provider.request({ method: 'eth_requestAccounts' })
                .then((result) => {
                    t.setState({value: activeMetamask});
                })
                .catch((error) => {
                });
        } catch (error) {
        }
    }

    getDisplay () {
        return this.state.value === installMetamask ? "Install Metamask"
            : this.state.value === loginMetamask ? "Login to Metamask"
            : "This message should be hidden";
    }

    render () {
        if (this.state.value === activeMetamask) {
            return (<div></div>);
        } else
        return (
                <button className="button" onClick={this.handleClick}>
                {this.getDisplay()}
                </button>
        );
    }
}

class AdminInterface extends React.Component {
    constructor(props) {
        super (props);

        this.changeHandler = this.changeHandler.bind(this);
        this.handleSubmit = this.handleSubmit.bind(this);

        this.state = {
        };
    }

    componentDidMount() {
        siteContract.then((sc) => {
            sc.methods.getNumArtist().call().then((na) => {
                this.setState({numArtists: na});
            });
        });
    }

    changeHandler (v) {
        this.setState({address: v.target.value});
    }

    async handleSubmit (t) {
        t.preventDefault();
        const address = this.state.address;
        addArtist(address).then((receipt) => {
            alert("added artist");
        });
    }

    render () {
        return (
                <div className="adminInterface">
                <h1>Admin Interface</h1>
                <div>
                    <label>Artist address
                    <input type="text" id="artist_address" name="artist_address" onChange={this.changeHandler}/>
                    </label>
                    <button className="button" onClick={this.handleSubmit} type="button">
                    Submit
                    </button>
                </div>
                <div>
                Number of artists is currently: {this.state.numArtists}
                </div>
                </div>
        );
    }
}

class ArtistInterface extends React.Component {
    constructor (props) {
        super (props);

        this.nameChangeHandler = this.nameChangeHandler.bind(this);
        this.descriptionChangeHandler = this.descriptionChangeHandler.bind(this);
        this.imageChangeHandler = this.imageChangeHandler.bind(this);
        this.featureEndChangeHandler = this.featureEndChangeHandler.bind(this);
        this.handleSubmit = this.handleSubmit.bind(this);
        this.profileSubmit = this.profileSubmit.bind(this);

        this.state = {
        };
    }

    componentDidMount() {
        const thisComponent = this;
        userAccount.then ((account) => {
            getArtist(account).then((artist) => {
                thisComponent.setState({artistName: artist[0], artistDescription: artist[1]});
            });
        });
    }

    nameChangeHandler (event) {
        this.setState({artistName: event.target.value});
    }

    descriptionChangeHandler (event) {
        this.setState({artistDescription: event.target.value});
    }

    imageChangeHandler (event) {
        this.setState({file: event.target.files[0]});
    }

    featureEndChangeHandler (event) {
        const localEndTime = new Date(event.target.value);
        this.setState({featureEndTime: localEndTime.getTime() / 1000});
    }

    profileSubmit () {
        const thisComponent = this;
        userAccount.then ((account) => {
            modifyArtistProfile(thisComponent.state.artistName, thisComponent.state.artistDescription).then((result) => {
                alert("modified profile");
            });
        });
    }

    async handleSubmit () {
        const thisFile = this.state.file;
        const featureEndTime = this.state.featureEndTime;
        const reader = new FileReader();

        if (! thisFile) {
            alert ("no file");
        } else {
            reader.readAsDataURL(thisFile);
            reader.onloadend = function() {
                const imageData = reader.result;

                controlStartArtWithFeature(featureEndTime, imageData).then(receipt => {
                    alert("new art created");
                }, err => {
                    alert(err.error);
                    console.log(err);
                });
            };
        }
    }

    // TODO eventually display dropdown for artist with list of completed bids to use to indentify art

    render () {
        return (
        <div className="artInterface">
            <h1>Artist Interface</h1>
            <div className="updateProfile">
                <label>Name
                <input type="text" name="artistNameField" onChange={this.nameChangeHandler} value={this.state.artistName}/>
                </label>
                <label>Bio
                <textarea name="artistDescriptionField" onChange={this.descriptionChangeHandler} rows="8" cols="120" value={this.state.artistDescription}/>
                </label>
                <button className="button" onClick={this.profileSubmit} type="button">Update Profile</button>
            </div>
            <div className="uploadArt">
                <form action="" method="post" encType="multipart/form-data">
                <label>Feature Auction Ends At:
                <input type="datetime-local" name="featureEndTime" id="featureEndTime" onChange={this.featureEndChangeHandler}/>
                </label>
                <label>Image:
                <input type="file" name="image" id="image-upload" onChange={this.imageChangeHandler} />
                </label>
                <button className="button" onClick={this.handleSubmit} type="button">New Art</button>
                </form>
            </div>
        </div>
        );
    }
}

class ArtListing extends React.Component {
    constructor (props) {
        super(props);

        this.changeBidAmount = this.changeBidAmount.bind(this);
        this.changeFeatureRequest = this.changeFeatureRequest.bind(this);
        this.imageChangeHandler = this.imageChangeHandler.bind(this);
        this.featureEndChangeHandler = this.featureEndChangeHandler.bind(this);
        this.toggleCompleteArtwork = this.toggleCompleteArtwork.bind(this);
        this.submitBid = this.submitBid.bind(this);
        this.completeFeature = this.completeFeature.bind(this);

        this.state = {
        };
    }

    changeBidAmount (event) {
        this.setState({myBidAmount:event.target.value});
    }

    changeFeatureRequest (event) {
        this.setState({myFeatureRequest:event.target.value});
    }

    imageChangeHandler (event) {
        this.setState({file: event.target.files[0]});
    }

    featureEndChangeHandler (event) {
        const localEndTime = new Date(event.target.value);
        this.setState({featureEndTime: localEndTime.getTime() / 1000});
    }

    toggleCompleteArtwork () {
        this.setState({completeArtwork: ! this.state.completeArtwork});
    }

    submitBid () {
        const myBid = this.state.myBidAmount;
        const myRequest = this.state.myFeatureRequest;
        const thisComponent = this;

        if (myBid * 1 <= this.state.bidAmount * 1) {
            alert("you must make a higher bid");
        } else {
            makeBid(this.props.artId, myRequest, myBid).then((receipt) => {
                alert("You are now the highest bidder!");
                thisComponent.setState({featureRequest:"Feature request: " + myRequest, bidAmount:"Bid amount: " + myBid});
            });
        }
    }

    componentDidMount() {
        getArtDisplay(this.props.artId).then((art) => {this.setState(art);});
    }

    completeFeature () {
        const artId = this.props.artId;
        const thisFile = this.state.file;
        const featureId = this.state.featureId;
        const completeArtwork = this.state.completeArtwork;
        const featureEndTime = this.state.featureEndTime;

        const reader = new FileReader();
        reader.readAsDataURL(thisFile);
        reader.onloadend = function () {
            const imageData = reader.result;
            controlCompleteFeature(artId, featureId, completeArtwork, featureEndTime, imageData).then(receipt => {
                //TODO choose correct message
                alert("art has been finished or bidding for next feature has started");
            }, err => {
                alert(err.error);
                console.log(err);
            });
        };
    }

    render () {
        return (
                <div className="artListing">
                <h3>{this.state.artistName}</h3>
                <img src={this.state.imgUrl}/>
                <div className="listingBid">
                    <div>{this.state.bidAmount}</div>
                    <div>{this.state.featureRequest}</div>
                </div>
                <p className="listingFeatureEnd">{this.state.timeText}</p>
                <div className="listingMakeBid">
                    <p>Request a feature</p>
                    <form action="" method="post" encType="multipart/form-data">
                    <label>Amount
                    <input type="text" name="myBidAmount" onChange={this.changeBidAmount}/>
                    </label>
                    <label>Request
                    <input type="text" name="myFeatureRequest" onChange={this.changeFeatureRequest} />
                    </label>
                    <button className="button" onClick={this.submitBid} type="button">Make Request</button>
                    </form>
                </div>

                {/* TODO logic for only displaying this for artists, and only after bidding finishes */}
                <div className="listingArtistOptions">
                    <p>Complete a feature</p>
                    <form action="" method="post" encType="multipart/form-data">
                    <label>Image:
                    <input type="file" name="image" onChange={this.imageChangeHandler} />
                    </label>
                    <label>Complete Artwork?
                    <input type="checkbox" name="finishArtwork" onChange={this.toggleCompleteArtwork} />
                    </label>
                    <label>Next Feature Auction Ends At:
                    <input type="datetime-local" name="featureEndTime" onChange={this.featureEndChangeHandler}/>
                    </label>
                    <button className="button" onClick={this.completeFeature} type="button">Complete Feature</button>
                    </form>
                </div>
                </div>
        );
    }
}

class ArtDisplay extends React.Component {
    constructor (props) {
        super (props);

        this.state = {
            artIds: []
        };
    }

    componentDidMount() {
        const thisComponent = this;
        getNumArt().then((na) => {
            var artIds = [];
            for (var i = 1; i <= 10 && na - i >= 0; i++) {
                var artId = na - i;
                artIds.push(artId);
            }
            thisComponent.setState({artIds:artIds});

            // listen for new art to display
            registerArtCreatedListener(artId => {
                console.log("new art id " + artId);
                var newList = thisComponent.state.artIds;
                newList.unshift(artId);
                thisComponent.setState({artIds: newList});
            });

            registerFeatureCreatedListener(featureId => {
                console.log("new feature id" + featureId);
                // stupid force redraw
                thisComponent.setState(thisComponent.state);
            });
            //TODO add NewBid event
        });
    }

    render () {
        const list = this.state.artIds.map((id) => {
            return (
                    <ArtListing artId={id}/>
            );
        });
        return (
                <div className="artDisplay">
                <h1>Art Listings</h1>
                {list}
                </div>
        );
    }
}

function App() {
    const [getTest, setTest] = useState("uninitialized dummy string");
    const [getAddr, setAddr] = useState("no address loaded");

    const messageGet = async (t) => {
	    t.preventDefault();
        siteContract.then((sc) => {
            sc.methods.getTestMessage().call().then((tm) => {
                setTest(tm);
            });
        });
    };

    userAccount.then ((ua) => {
        setAddr(ua);
    });

    return (
        <div className="main">
            <div>
            <img src="http://localhost:8081/caring_sam.jpg"/>
            </div>
            <div className="card">
                <MetaMaskButton />
                <div>{getAddr}</div>
                <button className="button" onClick={messageGet} type="button">
                Get message from Rinkeby contract
                </button>
                {getTest}
                <AdminInterface />
                <ArtistInterface />
                <ArtDisplay />
            </div>
       </div>
    );
}

export default App;
