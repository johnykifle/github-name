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
    { name : String }

type alias Model =
    { form : FormModel
    , gitHubData : GitHubModel
    }

init : () -> (Model, Cmd Msg)
init _ = 
    (model, Cmd.none)

initialFormUsername : String
initialFormUsername =
    ""

initialForm : FormModel
initialForm =
    { username = initialFormUsername, errors = [] }



model : Model
model =
    { form = 
        { initialForm | errors = validateForm initialForm initialFormUsername } 
    , gitHubData =
        { name = initialFormUsername
        }
    }

    
-- MESSAGE
type Msg
    = RequestGitHubData
    | ProcessGitHubHttpRequest (Result Http.Error Model)
    | InputUserName String
    
-- UPDATE

update : Msg -> Model -> (Model, Cmd Msg)
update msg newModel =
    case msg of 
        RequestGitHubData ->
            (newModel, requestGitHubData newModel.form)
        
        ProcessGitHubHttpRequest (Ok responseModel) ->
            (responseModel, Cmd.none)
        
        ProcessGitHubHttpRequest (Err _) ->
            (newModel, Cmd.none)
        
        InputUserName username ->
            ( { newModel | form = { username = username, errors = validateForm newModel.form username }}, Cmd.none )

validateForm : FormModel -> String -> List String
validateForm formModel newUserName =
    let
        errorMessage =
            "Username can not be blank"
        
        blankUserName =
            newUserName == ""
        
        errorMessageExists =
            List.member errorMessage formModel.errors

    in
    
        if blankUserName && errorMessageExists == False then
            formModel.errors ++ [ errorMessage ]
        else if blankUserName && errorMessageExists then
            formModel.errors
        else
            []

requestGitHubData : FormModel -> Cmd Msg
requestGitHubData formModel =
    Http.send ProcessGitHubHttpRequest (Http.get ("https://api.github.com/users/" ++ formModel.username) (decodeGitHubData formModel))

decodeGitHubData : FormModel -> Decode.Decoder Model
decodeGitHubData formModel =
    Decode.map2 Model (formModelDecoder formModel) gitHubModelDecoder

formModelDecoder : FormModel -> Decode.Decoder FormModel
formModelDecoder formModel =
    Decode.succeed formModel

gitHubModelDecoder : Decode.Decoder GitHubModel
gitHubModelDecoder =
    Decode.map GitHubModel (Decode.field "name" Decode.string)


-- Subscriptions

subscriptions : Model -> Sub Msg
subscriptions subModel =
    Sub.none

-- View

view : Model -> Html Msg
view existingModel =
    if existingModel.gitHubData.name == "" then
        div [] [ formView existingModel.form, formValidationView existingModel.form ]
    else
        dataView existingModel.gitHubData

formValidationView : FormModel -> Html Msg
formValidationView formModel =
    div [] [ text ( String.join "" formModel.errors ) ]

formView: FormModel -> Html Msg
formView formModel =
    div []
        [ input [ type_ "text", placeholder "Username", onInput InputUserName ] []
        , githubButtonView formModel
        ]

githubButtonView : FormModel -> Html Msg
githubButtonView formModel =
    if List.isEmpty formModel.errors then
        button [ onClick RequestGitHubData ]
            [ text "Gather data" ]
    else
        text ""

dataView : GitHubModel -> Html Msg
dataView exModel =
    div []
        [  text ("Username is " ++ exModel.name )]

main : Program () Model Msg
main = 
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }