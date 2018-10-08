module GitHubUser exposing (..)

import Browser
import Html exposing (Html, div, text, button, input)
import Html.Attributes exposing (type_, placeholder)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as Decode

-- Model
type alias FormModel =
    { username : String
    , errors : List String
    }

type alias GitHubModel =
    { name : String
    , login : String
    }

type alias Model =
    { form : FormModel
    , gitHubData : GitHubModel
    }

init : flags -> (Model, Cmd Msg)
init _ =
    (model, Cmd.none)

initialFormUserName : String
initialFormUserName =
    ""

initialForm : FormModel
initialForm =
    { username = initialFormUserName, errors = [] 
    }


model : Model
model =
    { form =
        {initialForm | errors = validateForm initialForm initialFormUserName}
    , gitHubData = 
        { name = initialFormUserName
        , login = initialFormUserName
        }
    }

-- Message
type Msg 
    = RequestGitHubData
    | ProcessGitHubHttpRequest (Result Http.Error Model)
    | InputUserName String

-- Update

update : Msg -> Model -> (Model, Cmd Msg)
update msg theModel =
    case msg of
        RequestGitHubData ->
            (theModel, requestGitHubData theModel.form)
        ProcessGitHubHttpRequest (Ok responseModel) ->
            ( responseModel, Cmd.none)
        ProcessGitHubHttpRequest (Err _) ->
            (model, Cmd.none)
        InputUserName username ->
            ( { theModel |  form = { username = username, errors = validateForm theModel.form username} }, Cmd.none)

requestGitHubData : FormModel -> Cmd Msg
requestGitHubData formModel =
    Http.send ProcessGitHubHttpRequest (Http.get ("https://api.github.com/users/" ++ formModel.username)  (decodeGitHubData formModel))

decodeGitHubData : FormModel -> Decode.Decoder Model
decodeGitHubData formModel =
    Decode.map2 Model 
        (formModelDecoder formModel)
        gitHubModelDecoder

formModelDecoder : FormModel -> Decode.Decoder FormModel
formModelDecoder formModel =
    Decode.succeed formModel

gitHubModelDecoder : Decode.Decoder GitHubModel
gitHubModelDecoder =
    Decode.map2 GitHubModel 
        (Decode.field "name" Decode.string)
        (Decode.field "login" Decode.string)

-- Subscriptions

subscriptions : Model -> Sub Msg
subscriptions submodel =
    Sub.none

view: Model -> Html Msg
view myModel =
    if myModel.gitHubData.name == "" then
        div [] [formView myModel.form, formValidationView myModel.form]
    else
        dataView myModel.gitHubData

formView : FormModel -> Html Msg
formView formModel =
    div []
        [ input [type_ "text" , placeholder "github username", onInput InputUserName] []
        , gitHubButtonView formModel
        ]

formValidationView : FormModel -> Html Msg
formValidationView formModel =
    div [] [ text (String.join "" formModel.errors)]

dataView : GitHubModel -> Html Msg
dataView gitHubData =
    div [] 
        [ div [] [ text ("user name is " ++ gitHubData.name ) ]
        , div [] [ text ("user login is " ++ gitHubData.login ) ]
        ]
gitHubButtonView : FormModel -> Html Msg
gitHubButtonView fm =
    if List.isEmpty fm.errors then
        button [ onClick RequestGitHubData] [ text "Gather data"]
    else
        text ""


validateForm : FormModel -> String -> List String
validateForm formModel newUsername =
    let
        errorMessage =
            "Username cannot be blank"
        
        blankUserName =
            newUsername == ""
        
        errorMessageExists =
            List.member errorMessage formModel.errors
    in

    if blankUserName && errorMessageExists == False then
        formModel.errors ++ [ errorMessage ]
    else if blankUserName && errorMessageExists then
        formModel.errors
    else
        []

    

main : Program () Model Msg
main = 
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }