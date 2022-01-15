import React, { useState } from "react";
import logo from './logo.svg';
import './App.css';

import { api } from './backend/ethereum';

class MetaMaskButton extends React.Component {
    constructor(props) {
	super(props);

        this.handleClick = this.handleClick.bind(this);
        this.getDisplay = this.getDisplay.bind(this);
	this.controls = api.makeWeb3LoginControls();
    }

    componentDidMount() {
	    this.controls.initComponent(_ => this.setState({initSuccess: true}));
    }

    handleClick () {
	    this.controls.handleClick(_ =>  this.setState({success: true}));
    }

    getDisplay () {
	    this.controls.getDisplay();
    }

    render () {
        if (this.controls.shouldHide()) {
            return (<div></div>);
        } else
        return (
                <button className="button" onClick={this.controls.handleClick}>
                {this.controls.getDisplay()}
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
	
	this.controls = api.makeAdminControls();
    }

    componentDidMount() {
	    this.controls.initComponent(na => this.setState({numArtists: na}));
    }

    changeHandler (v) {
        this.setState({address: v.target.value});
    }

    handleSubmit (t) {
	t.preventDefault();
       	const address = this.state.address;
	this.controls.handleSubmit(address, _ => {
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
	
	this.controls = api.makeArtistControls();
    }

    componentDidMount() {
        const thisComponent = this;
	this.controls.initComponent(a => thisComponent.setState(a));
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
	this.controls.profileSubmit(this.state.artistName, this.state.artistDescription, _ => 
		alert("modified profile"));
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

                api.controlStartArtWithFeature(featureEndTime, imageData).then(receipt => {
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
            this.props.artData.makeBid(myRequest, myBid).then((receipt) => {
                alert("You are now the highest bidder!");
		    // redraw?
            });
        }
    }

    completeFeature () {
        const thisFile = this.state.file;
        const completeArtwork = this.state.completeArtwork;
        const featureEndTime = this.state.featureEndTime;

        const reader = new FileReader();
        reader.readAsDataURL(thisFile);
        reader.onloadend = function () {
            const imageData = reader.result;

            this.props.artData.completeFeature(completeArtwork, featureEndTime, imageData).then(receipt => {
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
                <h3>{this.props.artData.artistName}</h3>
                <img src={this.props.artData.imgUrl}/>
                <div className="listingBid">
                    <div>{this.props.artData.bidAmount}</div>
                    <div>{this.props.artData.featureRequest}</div>
                </div>
                <p className="listingFeatureEnd">{this.props.artData.timeText}</p>
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
            artList: []
        };
    }

    componentDidMount() {
        const thisComponent = this;

	    api.getArtList().then(al => thisComponent.setState({artList:al}));

            // listen for new art to display
            api.registerFeatureCreatedListener(featureId => {
		    api.getArtList().then(al => thisComponent.setState({artList:al}));
            });

            //TODO add NewBid event
    }

    render () {
        const list = this.state.artList.map(s => {
            return (
                    <ArtListing artData={s}/>
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
	    /*
        api.siteContract.then((sc) => {
            sc.methods.getTestMessage().call().then((tm) => {
                setTest(tm);
            });
        });
	*/
    };

    api.userAccount.then ((ua) => {
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
