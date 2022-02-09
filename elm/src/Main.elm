module Main exposing (main)

import OutsideInfo exposing (..)
import Dict exposing (Dict, empty, update, get)
import Json.Decode exposing (Value)
import Time exposing (millisToPosix, posixToMillis, Posix, now, Weekday(..), toYear, toMonth, toDay, utc, Month(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Browser.Navigation as Navigation
import Browser exposing (UrlRequest)
import Url exposing (Url)
import Url.Parser as UrlParser exposing ((</>), Parser, s, top)
import Bootstrap.Alert as Alert
import Bootstrap.Badge as Badge
import Bootstrap.Dropdown as Dropdown
import Bootstrap.Navbar as Navbar
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Card as Card
import Bootstrap.Form as Form
import Bootstrap.Card.Block as Block
import Bootstrap.Button as Button
import Bootstrap.ListGroup as ListGroup
import Bootstrap.Tab as Tab
import Bootstrap.Text as Text
import Bootstrap.Form.Textarea as Textarea
import Bootstrap.Utilities.Flex as Flex
import Bootstrap.Utilities.Spacing as Spacing
import File exposing (File)
import File.Select as Select
import Task

type alias Flags =
  {}

type alias Model =
  { navKey : Navigation.Key
  , bioDraft : String
  , artistAddress : String -- TODO: maybe make it maybe
  , registerFeatureCreatedListenerList : List Int
  , registerArtCreatedListenerList : List Int
  , listArt : List Value
  , finishArt : Maybe Bool
  , controlStartArtWithFeature : Maybe Bool
  , nextFeature : Maybe Bool
  , makeBid : Maybe Value
  , startFeature : Maybe Bool
  , startArtWithFeature : Maybe Bool
  , modifyArtistProfile : Maybe Bool
  , getBid : Maybe Value
  , getDisplayFeature : Maybe Int
  , getFeature : Maybe Value
  , getArt : Maybe Value
  , getNumArtist : Maybe Int
  , getNumArt : Maybe Int
  , getArtist : Maybe Value
  , getArtistError : Maybe Value
  , addArtistReceiverState : Maybe Bool
  -- , getArtistSuccess : Maybe Bool
  , page : Page
  , navState : Navbar.State
  , artListings : ArtListingsDict
  , artistState : ArtistState
  , today : Maybe Posix
  , tabState : Tab.State
  , fromJavascript : String
  , fromJSgetArtDisplayRecv : (Int, Maybe Value) -- (argument to JS getArtDisplay, {artistName, imgUrl, timeText, bidAmount, featureRequest, artId, featureId})
  , requestsDict : Dict Int String -- Int represent the artListing's id
  , requestsPaymentDict : Dict Int Int -- First Int represent the artListing's id, second represent payment
  }

type alias ArtistState =
  { loggedArtist : Maybe Artist
  , artFile : Maybe File
  , imagePreview : String -- empty string represents no image preview
  , selectedAuctionEndDate : Maybe Posix
  , newListingErrorVisibility : Alert.Visibility
  , title : String
  , auctionEndDropdown : Dropdown.State
  }

type Msg
  = GetNumArtistReceiver Int
  | GetNumArtistSend
  | BioDraft String
  | RegisterFeatureCreatedListener Int
  | RegisterArtCreatedListener Int
  | ControlStartArtWithFeatureReceiver Bool
  | ControlStartArtWithFeatureSend (String, String)
  | GetArtListSend
  | GetArtListReceiver (List Value)
  | FinishArtReceiver Bool
  | FinishArtSend Int
  | NextFeatureReceiver Bool
  | NextFeatureSend (Int, Int)
  | MakeBidReceiver Value
  | MakeBidSend (Int, String)
  | StartFeatureReceiver Bool
  | StartFeatureSend (Int, Int)
  | StartArtWithFeatureReceiver Bool
  | StartArtWithFeatureSend
  | ModifyArtistProfileReceiver Bool
  | ModifyArtistProfileSend (String, String)
  | GetBidReceiver Value
  | GetBidSend Int
  | GetDisplayFeatureReceiver Int
  | GetDisplayFeatureSend Int
  | GetFeatureReceiver Value
  | GetFeatureSend Int
  | GetArtReceiver Value
  | GetArtSend Int
  | GetNumArtSend
  | GetNumArtReceiver Int
  | GetArtistReceiver Value
  | GetArtistErrorReceiver Value
  | GetArtistSend String
  | AddArtistSend String
  | TestMsg
  | AddArtistReceiver Bool
  | Recv String
  | GetArtDisplaySend Int
  | GetArtDisplayRecv Int Value
  | UrlChange Url
  | ClickedLink UrlRequest
  | NavMsg Navbar.State
  | PickFile
  | GotSelectedFile File
  | GotPreview String
  | PrepareListing Alert.Visibility
  | NewListing ArtListing
  | SetTitle String
  | SetArtist String
  | SetArtistAddress String
  | ReceiveDate Posix
  | TabMsg Tab.State
  | AuctionEndDropdown Dropdown.State
  | SetAuctionDays Int
  | SetRequestDraft Int String
  | SetRequestPaymentDraft Int String
  | SetRequest Int (Maybe Int) (Maybe String)

type alias ArtListing =
  { art : File
  , preview : String
  , title : String
  , biddingEnding : Posix
  , biddingStart : Posix
  , artist : Artist
  , requests : List (String, Int)
  }

type alias Artist =
  { name : String
  -- , wallet : String
  }

type Page
  = ArtListingsInterface
  | ArtistInterface
  | AdminInterface
  | LoginInterface
  | NotFound

type ArtListingsDict = ArtListingsDict (Dict Int ArtListing) -- Int represents id of ArtListing

main : Program Flags Model Msg
main = Browser.application
  { init = init
  , view = view
  , update = update
  , subscriptions = subscriptions
  , onUrlRequest = ClickedLink
  , onUrlChange = UrlChange
  }

init : Flags -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init flags url key =
  let ( navState, navCmd ) = Navbar.initialState NavMsg
      ( model, urlCmd ) = urlUpdate url
                            -- { navKey = key
                            -- , navState = navState
                            -- , page = ArtListingsInterface
                            -- , artListings = []
                            -- , today = Nothing
                            -- , tabState = Tab.initialState
                            -- , fromJavascript = "some initial msg"
                            -- , artistState = { loggedArtist = Nothing
                            --                 , artFile = Nothing
                            --                 , imagePreview = ""
                            --                 , selectedAuctionEndDate = Nothing
                            --                 , newListingErrorVisibility = Alert.closed
                            --                 , title = ""
                            --                 , auctionEndDropdown = Dropdown.initialState
                            --                 }
                            -- }--
                            { navKey = key
                            , listArt = []
                            , bioDraft = "init model draft"
                            , controlStartArtWithFeature = Nothing
                            , artistAddress = "hhefesto"
                            , navState = navState
                            , page = ArtListingsInterface
                            , artListings = ArtListingsDict Dict.empty
                            , today = Nothing
                            , tabState = Tab.initialState
                            , fromJavascript = "some initial msg"
                            , requestsDict = empty
                            , requestsPaymentDict = empty
                            , fromJSgetArtDisplayRecv = (0, Nothing) -- ¿TODO Maybe Int?
                            , getArtistError = Nothing
                            , addArtistReceiverState = Nothing
                            , getArtist = Nothing
                            , getNumArt = Nothing
                            , getNumArtist = Nothing
                            , getArt = Nothing
                            , getFeature = Nothing
                            , getDisplayFeature = Nothing
                            , getBid = Nothing
                            , modifyArtistProfile = Nothing
                            , startArtWithFeature = Nothing
                            , startFeature = Nothing
                            , makeBid = Nothing
                            , nextFeature = Nothing
                            , finishArt = Nothing
                            , registerArtCreatedListenerList = []
                            , registerFeatureCreatedListenerList = []
                            , artistState = { loggedArtist = Just { name = "hhefesto" }
                                            , artFile = Nothing
                                            , imagePreview = ""
                                            , selectedAuctionEndDate = Nothing
                                            , newListingErrorVisibility = Alert.closed
                                            , title = "adjoints"
                                            , auctionEndDropdown = Dropdown.initialState
                                            }
                            }
  in ( model
     , Cmd.batch
         [ Time.now |> Task.perform ReceiveDate
         , urlCmd
         , navCmd
         ]
     )

subscriptions : Model -> Sub Msg
subscriptions model = Sub.batch [ Navbar.subscriptions model.navState NavMsg
                                , Tab.subscriptions model.tabState TabMsg
                                , Alert.subscriptions model.artistState.newListingErrorVisibility PrepareListing
                                , messageReceiver Recv
                                , getBidReceiver GetBidReceiver
                                , getDisplayFeatureReceiver GetDisplayFeatureReceiver
                                , getFeatureReceiver GetFeatureReceiver
                                , getArtReceiver GetArtReceiver
                                , getNumArtistReceiver GetNumArtistReceiver
                                , getNumArtReceiver GetNumArtReceiver
                                , addArtistReceiver AddArtistReceiver
                                , getArtistReceiver GetArtistReceiver
                                , getArtistErrorReceiver GetArtistErrorReceiver
                                , modifyArtistProfileReceiver ModifyArtistProfileReceiver
                                , startArtWithFeatureReceiver StartArtWithFeatureReceiver
                                , startFeatureReceiver StartFeatureReceiver
                                , makeBidReceiver MakeBidReceiver
                                , nextFeatureReceiver NextFeatureReceiver
                                , finishArtReceiver FinishArtReceiver
                                , getArtListReceiver GetArtListReceiver
                                , controlStartArtWithFeatureReceiver ControlStartArtWithFeatureReceiver
                                , registerArtCreatedListener RegisterArtCreatedListener
                                , registerFeatureCreatedListener RegisterFeatureCreatedListener
                                , getArtDisplayReceiver << GetArtDisplayRecv  << Tuple.first <| model.fromJSgetArtDisplayRecv
                                , Dropdown.subscriptions model.artistState.auctionEndDropdown AuctionEndDropdown
                                ]

setImagePreview : String -> ArtistState -> ArtistState
setImagePreview url sart = { sart | imagePreview = url }

setArtistState : Model -> ArtistState -> Model
setArtistState model sart = { model | artistState = sart }

setDate : ArtistState -> Maybe Posix -> ArtistState
setDate sart date = { sart | selectedAuctionEndDate = date }

setPrepareListingErrorVisibility : ArtistState -> Alert.Visibility -> ArtistState
setPrepareListingErrorVisibility sart av = { sart | newListingErrorVisibility = av }

setTitle : ArtistState -> String -> ArtistState
setTitle sart str = { sart | title = str }

setArtist : ArtistState -> String -> ArtistState
setArtist sart str = if str == ""
                     then { sart | loggedArtist = Nothing }
                     else { sart | loggedArtist = Just { name = str } }

setArtFile : ArtistState -> File -> ArtistState
setArtFile sart file = { sart | artFile = Just file }

-- TODO: something cleaner
fromJust : Maybe a -> a
fromJust mx = case mx of
  (Just x) -> x
  Nothing -> Debug.todo "error: fromJust Nothing"

setAuctionEndDropdown : ArtistState -> Dropdown.State -> ArtistState
setAuctionEndDropdown sart s = { sart | auctionEndDropdown = s }

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model = case msg of
  BioDraft str -> ({ model | bioDraft  = str }
                  , Cmd.none
                  )
  SetArtistAddress str -> ({ model | artistAddress  = str }
                          , Cmd.none
                          )
  RegisterFeatureCreatedListener i -> ({ model | registerFeatureCreatedListenerList  = i :: model.registerFeatureCreatedListenerList }
                                      , Cmd.none
                                      )
  RegisterArtCreatedListener i -> ({ model | registerArtCreatedListenerList  = i :: model.registerArtCreatedListenerList }
                                  , Cmd.none
                                  )

  ControlStartArtWithFeatureReceiver bool -> ({ model | controlStartArtWithFeature = Just bool}, Cmd.none)
  ControlStartArtWithFeatureSend pair -> (model, controlStartArtWithFeatureSend <| Debug.log "ControlStartArtWithFeatureSend pair: " pair)
  GetArtListReceiver lst -> ({ model | listArt = lst}, Cmd.none)
  GetArtListSend -> (model, getArtListSend ())
  FinishArtReceiver bool -> ({ model | finishArt = Just bool}, Cmd.none)
  FinishArtSend i -> (model, finishArtSend i)
  NextFeatureReceiver bool -> ({ model | nextFeature = Just bool}, Cmd.none)
  NextFeatureSend pair -> (model, nextFeatureSend pair)
  MakeBidReceiver value -> ({ model | makeBid = Just value}, Cmd.none)
  MakeBidSend pair -> (model, makeBidSend pair)
  StartFeatureReceiver bool -> ({ model | startFeature = Just bool}, Cmd.none)
  StartFeatureSend int_pair -> (model, startFeatureSend int_pair)
  StartArtWithFeatureSend -> (model, startArtWithFeatureSend ())
  StartArtWithFeatureReceiver bool -> ({ model | startArtWithFeature = Just bool}, Cmd.none)
  ModifyArtistProfileSend string_pair -> (model, modifyArtistProfileSend string_pair)
  ModifyArtistProfileReceiver bool -> ({ model | modifyArtistProfile = Just bool}, Cmd.none)
  GetBidReceiver value -> ({ model | getBid = Just value }, Cmd.none)
  GetBidSend i -> (model, getBidSend i)
  GetDisplayFeatureReceiver i -> ({ model | getDisplayFeature = Just i }, Cmd.none)
  GetDisplayFeatureSend i -> (model, getDisplayFeatureSend i)
  GetFeatureReceiver value -> ({ model | getFeature = Just value }, Cmd.none)
  GetFeatureSend i -> (model, getFeatureSend i)
  GetArtReceiver value -> ({ model | getArt = Just value }, Cmd.none)
  GetArtSend i -> (model, getArtSend i)
  GetNumArtistSend -> (model, getNumArtistSend ())
  GetNumArtistReceiver i -> ({ model | getNumArtist = Just i }, Cmd.none)
  GetNumArtSend -> (model, getNumArtSend ())
  GetNumArtReceiver i -> ({ model | getNumArt = Just i }, Cmd.none)
  GetArtistErrorReceiver value -> ({ model |  getArtistError = Just value }, Cmd.none)
  GetArtistReceiver value -> ({ model | getArtist = Just value }, Cmd.none) -- TODO make model know about value
  GetArtistSend addr -> (model, getArtistSend addr)
  AddArtistReceiver bool -> ({ model | addArtistReceiverState = Just bool}, Cmd.none) -- TODO alert user graphically
  AddArtistSend addr -> (model, addArtistSend addr) -- TODO ¿should model change?
  GetArtDisplaySend i -> (model, getArtDisplaySend i)
  SetRequest i mpayment mstr ->
    case (mpayment,mstr) of
      (Just payment, Just request) ->
        case (payment > 0, request) of
          (False, _) -> (model, Cmd.none) -- TODO: throw alert saying that payment cannot be lower than 1
          (True, "") -> (model, Cmd.none) -- TODO: throw alert saying that a request cannot be an empty string
          (True, str) -> ({model | artListings = addRequestToArtListingsDict i payment str model.artListings}, Cmd.none)
      (_,_) -> (model, Cmd.none) -- TODO: throw alert saying that a request or payment not specified
  --( , Cmd.none)
  GetArtDisplayRecv i value -> ({ model | fromJSgetArtDisplayRecv = (i, Just value) }, Cmd.none)
  SetRequestPaymentDraft i str -> case str of
                            "" -> (model, Cmd.none)
                            _ -> case String.toInt str of
                                   Nothing -> (model, Cmd.none) -- TODO: throw alert saying int parse unsuccessful
                                   Just payment ->
                                     if payment < 0
                                     then (model, Cmd.none) -- TODO: throw alert saying payment must be greater than 0
                                     else ({model | requestsPaymentDict = Dict.update i (\x -> Just payment) model.requestsPaymentDict}, Cmd.none)
  SetRequestDraft i str -> case str of
                            "" -> (model, Cmd.none)
                            _ -> ({model | requestsDict = Dict.update i (\x -> Just str) model.requestsDict}, Cmd.none)
  SetAuctionDays i -> (setArtistState model <| setDate model.artistState
                                            <| Maybe.map (\posix -> millisToPosix <| posixToMillis posix + (i * 86400000) ) model.today, Cmd.none)
  AuctionEndDropdown state -> (setArtistState model <| setAuctionEndDropdown model.artistState state, Cmd.none)
  Recv incoming -> ({model | fromJavascript = incoming }, Cmd.none)
  -- GetArtDisplayRecv incoming ->

  TestMsg -> (model, sendMessage "something!")
  -- TestMsg -> (model, Cmd.none)
  TabMsg state ->
    ( { model | tabState = state }
    , Cmd.none
    )
  NewListing l -> ( { model | artListings = addToArtListingsDict l model.artListings }
                  , Task.perform ControlStartArtWithFeatureSend <| Task.succeed (String.fromInt((posixToMillis l.biddingEnding) // 1000), l.preview)
                  )
  ReceiveDate date -> ( { model | today = Just date }, Cmd.none)
  SetArtist str -> ( setArtistState model <| setArtist model.artistState str, Cmd.none )
  SetTitle str -> ( setArtistState model <| setTitle model.artistState str, Cmd.none )
  PrepareListing av -> if model.artistState.imagePreview == ""
                       || model.artistState.artFile == Nothing
                       || model.artistState.title == ""
                       || model.artistState.selectedAuctionEndDate == Nothing
                       || model.artistState.loggedArtist == Nothing
                       || model.today == Nothing
                       then ( setArtistState model <| setPrepareListingErrorVisibility model.artistState Alert.shown
                            , Cmd.none
                            )
                       else ( setArtistState model <| setPrepareListingErrorVisibility model.artistState av
                            , Task.perform NewListing <| Task.succeed
                                { art = fromJust model.artistState.artFile
                                , preview = model.artistState.imagePreview
                                , title = model.artistState.title
                                , biddingEnding = fromJust model.artistState.selectedAuctionEndDate
                                , biddingStart = fromJust model.today
                                , artist = fromJust model.artistState.loggedArtist
                                , requests = []
                                }
                            )
  GotPreview url -> ( setArtistState model <| setImagePreview url model.artistState -- { model | artistState = { model.artistState | imagePreview = url } }
                    , Cmd.none
                    )
  GotSelectedFile file -> ( setArtistState model <| setArtFile model.artistState file
                          , Task.perform GotPreview <| File.toUrl file
                          )
  PickFile -> (model, Select.file ["image/*"] GotSelectedFile)
  ClickedLink req -> case req of
    Browser.Internal url ->
      ( model, Navigation.pushUrl model.navKey <| Url.toString url )
    Browser.External href ->
      ( model, Navigation.load href )
  UrlChange url -> urlUpdate url model
  NavMsg state ->
    ( { model | navState = state }
    , Cmd.none
    )

urlUpdate : Url -> Model -> ( Model, Cmd Msg )
urlUpdate url model = case decode url of
  Nothing -> ( { model | page = NotFound }, Cmd.none )
  Just route -> ( { model | page = route }, Cmd.none )

decode : Url -> Maybe Page
decode url = { url | path = Maybe.withDefault "" url.fragment, fragment = Nothing }
  |> UrlParser.parse routeParser

routeParser : Parser (Page -> a) a
routeParser = UrlParser.oneOf
  [ UrlParser.map ArtListingsInterface top
  , UrlParser.map ArtistInterface (UrlParser.s "artist")
  , UrlParser.map AdminInterface (UrlParser.s "admin")
  , UrlParser.map LoginInterface (UrlParser.s "login")
  ]

view : Model -> Browser.Document Msg
view model = let _ = Debug.log "Model" model in
  { title = "playNFT"
  , body =
      [ div []
          [ menu model
          , mainContent model
          ]
      ]
  }

menu : Model -> Html Msg
menu model = Navbar.config NavMsg
  |> Navbar.withAnimation
  |> Navbar.container
  |> Navbar.brand [ href "#" ] [ text "playNFT" ]
  |> Navbar.items
      [ Navbar.itemLink [ href "#artist" ] [ text "Artist Interface" ]
      , Navbar.itemLink [ href "#admin" ] [ text "Administrator Interface" ]
      ]
  -- |> Navbar.attrs [ class "navbar navbar-expand-lg navbar-dark navbar-custom fixed-top" ]
  |> Navbar.customItems
     [ Navbar.formItem [ href "#login" ]
       [ Button.button
         [ Button.roleLink
         , Button.attrs [ Spacing.ml2Sm
                        , href "#login"
                        ]
         ]
         [ text "Login"]
       ]
     -- , Navbar.textItem [ Spacing.ml2Sm, class "muted" ] [ text "Text"]
     ]
  |> Navbar.view model.navState

mainContent : Model -> Html Msg
mainContent model = Grid.container [] <|
  case model.page of
    ArtListingsInterface -> pageArtListingsInterface model
    ArtistInterface -> pageArtistInterface model
    AdminInterface -> pageAdminInterface model
    LoginInterface -> pageLoginInterface model
    NotFound -> pageNotFound


viewPreview : String -> Html msg
viewPreview url = div
  [ style "width" "60px"
  , style "height" "60px"
  , style "background-image" ("url('" ++ url ++ "')")
  , style "background-position" "center"
  , style "background-repeat" "no-repeat"
  , style "background-size" "contain"
  ]
  []

makeOwnerCardFromListing : ArtListing -> Html Msg
makeOwnerCardFromListing artListing =
  Card.config []
    |> Card.header [ class "text-center" ]
        [ img [ src artListing.preview
              , style "max-width" "100%"
              , style "height" "auto"
              ]
              []
        , h3 [ Spacing.mt2 ] [ text artListing.title
                             ]
        ]
    |> Card.block []
        -- [ Block.text [] [ text <| "Artist: " ++ artListing.artist.name ]
        [ Block.text [] [ text <| "Bidding ending at: " ++ String.fromInt (toYear utc artListing.biddingEnding)
                                                        ++ "-" ++ monthToString (toMonth utc artListing.biddingEnding)
                                                        ++ "-" ++ String.fromInt (toDay utc artListing.biddingEnding)
                                                        ++ " UTC"]
        , Block.titleH4 [] [ text <| "Requests:" ]
        , Block.custom <|
            case artListing.requests of
                [] -> ListGroup.ul
                        [ ListGroup.li [] [text "No requests so far."] ]
                ls -> ListGroup.ul <|
                        List.map (\ (str,i) -> ListGroup.li
                                                 [ ListGroup.attrs [ Flex.block, Flex.justifyBetween, Flex.alignItemsCenter ] ]
                                                 [ text str
                                                 , Badge.pillSuccess [] [ text <| String.fromInt i ++ " wei (eth)" ]
                                                 ]
                                 )
                                 artListing.requests -- TODO: show request and crypto amount
        ]
    |> Card.view

makePublicCardFromListing : Model -> Int -> ArtListing -> Html Msg
makePublicCardFromListing model artListingId artListing =
  Card.config []
    |> Card.header [ class "text-center" ]
        [ img [ src artListing.preview
              , style "max-width" "100%"
              , style "height" "auto"
              ]
              []
        , h3 [ Spacing.mt2 ] [ text artListing.title
                             ]
        ]
    |> Card.block []
        [ Block.text [] [ text <| "Artist: " ++ artListing.artist.name ]
        , Block.text [] [ text <| "Bidding ending at: " ++ String.fromInt (toYear utc artListing.biddingEnding)
                                                        ++ "-" ++ monthToString (toMonth utc artListing.biddingEnding)
                                                        ++ "-" ++ String.fromInt (toDay utc artListing.biddingEnding)
                                                        ++ " UTC"]
        , Block.titleH4 [] [ text "Make a request:" ]
        , Block.text [] [ text "Request: "
                        , Textarea.textarea
                            [ Textarea.rows 2
                            , Textarea.onInput <| SetRequestDraft artListingId
                            ]
                        , br [] []
                        , text "Your bid (ETH): "
                        , input [ placeholder "amount in ETH (wei)"
                                , style "margin" "10px"
                                , onInput <| SetRequestPaymentDraft artListingId
                                ]
                                []
                        , Button.button
                            [ Button.primary
                            -- , Button.large
                            -- , Button.block
                            , Button.attrs [ onClick <| SetRequest artListingId
                                                                   (Dict.get artListingId model.requestsPaymentDict)
                                                                   (Dict.get artListingId model.requestsDict)
                                           ]
                            ]
                            [ text "New Request" ]
                        ]
        ]
    |> Card.view


monthToString : Month -> String
monthToString month =
  case month of
    Jan -> "Jan"
    Feb -> "Feb"
    Mar -> "Mar"
    Apr -> "Apr"
    May -> "May"
    Jun -> "Jun"
    Jul -> "Jul"
    Aug -> "Aug"
    Sep -> "Sep"
    Oct -> "Oct"
    Nov -> "Nov"
    Dec -> "Dec"

pageArtistInterface : Model -> List (Html Msg)
pageArtistInterface model =
  [ Grid.row []
      [ Grid.col [ Col.textAlign Text.alignXsCenter ]
          [ br [] []
          , h1 [] [ text "Artist Interface" ]
          , br [] []
          ]
      ]
  , Grid.row []
      [ Grid.col []
          [ Tab.config TabMsg
              |> Tab.withAnimation
              -- |> Tab.fill
              |> Tab.items
                   [ Tab.item
                       { id = "artistListingsTab"
                       , link = Tab.link [] [ text "My Listings" ]
                       , pane = Tab.pane [] <| artistListingsTab model
                       }
                   , Tab.item
                       { id = "newArtListingTab"
                       , link = Tab.link [] [ text "New Art Listing" ]
                       , pane = Tab.pane [] <| artistNewArtListingTab model
                       }
                   , Tab.item
                       { id = "artistProfileTab"
                       , link = Tab.link [] [ text "Profile" ]
                       , pane = Tab.pane [] <| artistProfileTab model
                       }
                   ]
              |> Tab.view model.tabState
          ]
      ]
  ]

artistProfileTab : Model -> List (Html Msg)
artistProfileTab model =
  [ Grid.row [] [ Grid.col [ Col.textAlign Text.alignXsCenter ]
                           [ br [] []
                           , h2 [] [ text <| case model.artistState.loggedArtist of
                                               Just artist -> "Welcome, " ++ artist.name ++ "!"
                                               Nothing -> "Hello, stranger! Specify your artist name to log in."
                                   ]
                           ]
                ]
  , Grid.row [] [ Grid.col [ Col.textAlign Text.alignXsCenter ]
                           [ br [] []
                           , text "Artist: "
                           , input [ placeholder "Artist's name", onInput SetArtist ] []
                           , br [] []
                           , br [] []
                           , text "Bio:"
                           , Textarea.textarea
                               [ Textarea.rows 2
                               -- , Textarea.value "Write your own bio ;)"
                               -- , Textarea.placeholder "Artist's name"
                               , Textarea.onInput BioDraft

                               ]
                           , br [] []
                           , Button.button
                               [ Button.secondary
                               , Button.large
                               , Button.block
                               , Button.attrs [ onClick <| case (model.artistState.loggedArtist, model.bioDraft) of
                                                             (_,"") -> ModifyArtistProfileSend ("TODO: improve this", "TODO: improve this")
                                                             (Nothing, bioDraft) -> ModifyArtistProfileSend ("TODO: improve this", "TODO: improve this")
                                                             (Just a, bioDraft) -> ModifyArtistProfileSend (a.name, bioDraft)
                                              ]
                               ]
                               [ text "Update profile" ]
                           ]
                ]
  ]

imagePlaceholderOrPreview : Model -> String
imagePlaceholderOrPreview model = if model.artistState.imagePreview == ""
                                  then "data:image/png;base64,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"
                                  else model.artistState.imagePreview

artistNewArtListingTab : Model -> List (Html Msg)
artistNewArtListingTab model =
  [ Grid.row []
      [ Grid.col []
          [ br [] []
          , h2 [] [
                  ]
          ]
      ]
  , Grid.row []
      [ Grid.col []
          [ br [] []
          , Card.config []
              |> Card.header [ class "text-center" ]
                  [ img [ src <| imagePlaceholderOrPreview model
                        , style "max-width" "100%"
                        , style "height" "auto"
                        ]
                        []
                  , h3 [ Spacing.mt2 ] [ if model.artistState.title == ""
                                         then text "Set a title for your new art listing."
                                         else text model.artistState.title
                                       ]
                  ]
              |> Card.block []
                  [ Block.titleH4 [] [ text "New Art Listing's content:" ]
                  , Block.custom <|
                      Button.button
                        [ Button.secondary
                        , Button.large
                        , Button.block
                        , Button.attrs [ onClick PickFile ]
                        ]
                      [ text "Select Art File" ]

                  , Block.text [] [ text "Title: "
                                  , input [ placeholder "Your art's tile"
                                          , onInput SetTitle
                                          , style "margin" "10px"
                                          ]
                                          []
                                  , Dropdown.dropdown
                                      model.artistState.auctionEndDropdown
                                      { options = [ Dropdown.attrs [ style "margin" "10px" ] ]
                                      , toggleMsg = AuctionEndDropdown
                                      , toggleButton =
                                          Dropdown.toggle [ Button.primary ] [ text "Pick auction's duration" ]
                                      , items =
                                          [ Dropdown.buttonItem [ onClick <| SetAuctionDays 1 ] [ text "1 day" ]
                                          , Dropdown.buttonItem [ onClick <| SetAuctionDays 2 ] [ text "2 days" ]
                                          ]
                                      }
                                  ]
                  , Block.custom <|
                      Button.button
                        [ Button.primary
                        , Button.large
                        , Button.block
                        , Button.attrs [ onClick <| PrepareListing Alert.closed ]
                        ]
                        [ text "New Art Listing" ]
                  ]
              |> Card.view
          ]
      ]
  , br [] []
  , Alert.config
      -- |> Alert.dismissable PrepareListing
      |> Alert.warning
      |> Alert.children
          [ Alert.h4 [] [ text "Not a complete art listing" ]
          , text "You must select a file and an auction date end."
          ]
      |> Alert.view model.artistState.newListingErrorVisibility
  ]

pageLoginInterface : Model -> List (Html Msg)
pageLoginInterface model =
  [ Grid.row []
      [ Grid.col [ Col.textAlign Text.alignXsCenter ]
          [ br [] []
          , h1 [] [ text "Login Interface" ]
          , br [] []
          ]
      ]
  , Grid.row []
      [ Grid.col [] [ h4 [] [ text "Artist's address:" ]
                    , input [ placeholder "Your wallet's address"
                            , size 30
                            , style "margin" "10px"
                            ]
                        []
                    , Button.button [] [ text "Submit" ]
                    ]
      ]
  ]

pageAdminInterface : Model -> List (Html Msg)
pageAdminInterface model =
  [ Grid.row []
      [ Grid.col [ Col.textAlign Text.alignXsCenter ]
          [ br [] []
          , h1 [] [ text "Administrator Interface" ]
          , br [] []
          ]
      ]
  , Grid.row []
      [ Grid.col [] [ h4 [] [ text "Artist's address:" ]
                    , input [ placeholder "Your wallet's address"
                            , size 30
                            , style "margin" "10px"
                            , onInput <| SetArtistAddress
                            ]
                        []
                    , Button.button
                        [ Button.secondary
                        , Button.large
                        , Button.block
                        , Button.attrs [ onClick <| AddArtistSend model.artistAddress ]
                        ]
                        [ text "Add Artist" ]
                          -- Button.button [] [ text "Submit" ]
                    ]
      ]

  -- , Grid.row []
  --     [ Grid.col [ Col.md2 ] [ h4 [] [ text "Artist adress:" ] ]
  --     , Grid.col [] [ input [ placeholder "your art's tile"
  --                           , size 30
  --                           , style "margin" "10px"
  --                           ]
  --                       []
  --                   , Button.button [] [ text "Submit" ]
  --                   ]
  --     ]
  ]

pageNotFound : List (Html Msg)
pageNotFound =
  [ h1 [] [ text "Not found" ]
  , text "SOrry couldn't find that page"
  ]

intersperseBr : List (Html Msg) -> List (Html Msg)
intersperseBr lst = case lst of
  [] -> []
  (l::ls) -> [br [] [], l] ++ intersperseBr ls

pageArtListingsInterface : Model -> List (Html Msg)
pageArtListingsInterface model =
  [ Grid.row []
      [ Grid.col [ Col.textAlign Text.alignXsCenter ]
          [ br [] []
          , h1 [] [ text model.fromJavascript ]
          , br [] []
          , Button.button
              [ Button.secondary
              , Button.large
              , Button.block
              , Button.attrs [ onClick TestMsg ]
              ]
              [ text "Test Msg" ]
          ]
      ]
  , Grid.row []
      [ Grid.col [ Col.textAlign Text.alignXsCenter ]
          [ br [] []
          , Button.button
              [ Button.secondary
              , Button.large
              , Button.block
              , Button.attrs [ onClick <| AddArtistSend "0xD01990F227CcBF0626E09F3B61Df1221B9b85841" ]
              ]
              [ text "Add Artist" ]
          ]
      ]
  , Grid.row []
      [ Grid.col [ Col.textAlign Text.alignXsCenter ]
          [ br [] []
          , Button.button
              [ Button.secondary
              , Button.large
              , Button.block
              , Button.attrs [ onClick <| GetArtistSend "0xD01990F227CcBF0626E09F3B61Df1221B9b85841" ] -- success
              -- , Button.attrs [ onClick <| GetArtistSend "0xD01990F227CcBF0626E09F3B61Df1221B9b85840" ] -- error, but doesn't work TODO: FIX. See: app.ports.getArtistSend.subscribe(function(addr) {
              ]
              [ text "Get Artist" ]
          ]
      ]
  , Grid.row []
      [ Grid.col [ Col.textAlign Text.alignXsCenter ]
          [ br [] []
          , Button.button
              [ Button.secondary
              , Button.large
              , Button.block
              , Button.attrs [ onClick <| GetNumArtSend ] -- success
              ]
              [ text "getNumArt" ]
          ]
      ]
  , Grid.row []
      [ Grid.col [ Col.textAlign Text.alignXsCenter ]
          [ br [] []
          , Button.button
              [ Button.secondary
              , Button.large
              , Button.block
              , Button.attrs [ onClick <| GetNumArtistSend ] -- success
              ]
              [ text "getNumArtist" ]
          ]
      ]
   , Grid.row []
      [ Grid.col [ Col.textAlign Text.alignXsCenter ]
          [ br [] []
          , Button.button
              [ Button.secondary
              , Button.large
              , Button.block
              , Button.attrs [ onClick <| GetArtSend 0 ] -- success
              ]
              [ text "getArt" ]
          ]
      ]
  , Grid.row []
      [ Grid.col [ Col.textAlign Text.alignXsCenter ]
          [ br [] []
          , Button.button
              [ Button.secondary
              , Button.large
              , Button.block
              , Button.attrs [ onClick <| GetFeatureSend 0 ]
              ]
              [ text "getFeature" ]
          ]
      ]
  , Grid.row []
      [ Grid.col [ Col.textAlign Text.alignXsCenter ]
          [ br [] []
          , Button.button
              [ Button.secondary
              , Button.large
              , Button.block
              , Button.attrs [ onClick <| GetDisplayFeatureSend 0 ]
              ]
              [ text "getDisplayFeature" ]
          ]
      ]
  , Grid.row []
      [ Grid.col [ Col.textAlign Text.alignXsCenter ]
          [ br [] []
          , Button.button
              [ Button.secondary
              , Button.large
              , Button.block
              , Button.attrs [ onClick <| GetBidSend 0 ]
              ]
              [ text "getBid" ]
          ]
      ]
  , Grid.row []
      [ Grid.col [ Col.textAlign Text.alignXsCenter ]
          [ br [] []
          , Button.button
              [ Button.secondary
              , Button.large
              , Button.block
              , Button.attrs [ onClick <| ModifyArtistProfileSend ("string0", "string1") ]
              ]
              [ text "modifyArtistProfile" ]
          ]
      ]
  , Grid.row []
      [ Grid.col [ Col.textAlign Text.alignXsCenter ]
          [ br [] []
          , Button.button
              [ Button.secondary
              , Button.large
              , Button.block
              , Button.attrs [ onClick <| StartArtWithFeatureSend ]
              ]
              [ text "startArtWithFeature" ]
          ]
      ]
  , Grid.row []
      [ Grid.col [ Col.textAlign Text.alignXsCenter ]
          [ br [] []
          , Button.button
              [ Button.secondary
              , Button.large
              , Button.block
              , Button.attrs [ onClick <| StartFeatureSend (0,0) ]
              ]
              [ text "startFeature" ]
          ]
      ]
  , Grid.row []
      [ Grid.col [ Col.textAlign Text.alignXsCenter ]
          [ br [] []
          , Button.button
              [ Button.secondary
              , Button.large
              , Button.block
              , Button.attrs [ onClick <| MakeBidSend (0,"a-string") ]
              ]
              [ text "makeBid" ]
          ]
      ]
  , Grid.row []
      [ Grid.col [ Col.textAlign Text.alignXsCenter ]
          [ br [] []
          , Button.button
              [ Button.secondary
              , Button.large
              , Button.block
              , Button.attrs [ onClick <| NextFeatureSend (0,0) ]
              ]
              [ text "nextFeature" ]
          ]
      ]
  , Grid.row []
      [ Grid.col [ Col.textAlign Text.alignXsCenter ]
          [ br [] []
          , Button.button
              [ Button.secondary
              , Button.large
              , Button.block
              , Button.attrs [ onClick <| FinishArtSend 0 ]
              ]
              [ text "finishArt" ]
          ]
      ]
  , Grid.row []
      [ Grid.col [ Col.textAlign Text.alignXsCenter ]
          [ br [] []
          , Button.button
              [ Button.secondary
              , Button.large
              , Button.block
              , Button.attrs [ onClick <| GetArtListSend ]
              ]
              [ text "getArtList" ]
          ]
      ]
  , Grid.row []
      [ Grid.col [] << List.append [br [] [] ]
                    << intersperseBr
                    << Dict.values
                    << Dict.map (makePublicCardFromListing model)
                    << getArtListingsDict
                    <| model.artListings
      ]
  ]

artistListingsTab : Model -> List (Html Msg)
artistListingsTab model =
  [ Grid.row[]
      [ Grid.col [] <| intersperseBr <| List.map makeOwnerCardFromListing <|
          case model.artistState.loggedArtist of
            Nothing -> []
            Just artist -> Dict.values << Dict.filter (\k a -> a.artist.name == artist.name)
                                       <| getArtListingsDict model.artListings
      ]
  ]

getArtListingsDict : ArtListingsDict -> Dict Int ArtListing
getArtListingsDict (ArtListingsDict d) = d

addToArtListingsDict : ArtListing -> ArtListingsDict -> ArtListingsDict
addToArtListingsDict artListing (ArtListingsDict artListingsDict) =
  let nextId = case List.maximum << Dict.keys <| artListingsDict of
                 Nothing -> 0
                 Just x -> x + 1
  in ArtListingsDict << Dict.insert nextId artListing <| artListingsDict

addRequestToArtListingsDict : Int -> Int -> String -> ArtListingsDict -> ArtListingsDict
addRequestToArtListingsDict idArtListing payment request (ArtListingsDict artListingsDict) =
  let addRequest : Maybe ArtListing -> Maybe ArtListing
      addRequest mal =
        case mal of
          Nothing -> Nothing
          Just al -> Just { al | requests = al.requests ++ [(request,payment)] }
  in ArtListingsDict <| Dict.update idArtListing addRequest artListingsDict
