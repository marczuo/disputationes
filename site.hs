--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid (mappend)
import           Hakyll.Web.Sass
import           Hakyll
import           Data.List
import           Control.Arrow

import           Text.Blaze.Html                 (toHtml, toValue, (!))
import           Text.Blaze.Html.Renderer.String (renderHtml)
import qualified Text.Blaze.Html5                as H
import qualified Text.Blaze.Html5.Attributes     as A

--------------------------------------------------------------------------------
siteConfig :: Configuration
siteConfig = defaultConfiguration { deployCommand = "make deploy push" }

main :: IO ()
main = hakyllWith siteConfig $ do
    tags <- buildTags "posts/*" $ fromCapture "tags/*.html"

    match "images/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*.css" $ do
        route   idRoute
        compile compressCssCompiler

    match "css/*.sass" $ do
        route   $ setExtension "css"
        compile $ sassCompiler
            >>= compressCssBindable        -- See implementation below

    match "favicon.png" $ do
        route   idRoute
        compile copyFileCompiler

    match "about.markdown" $ do 
        let aboutCtx =
                constField "about" ""                        `mappend`
                defaultContext

        route   $ setExtension "html" 
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/default.html" aboutCtx
            >>= relativizeUrls

    match "posts/*" $ do
        route   $ setExtension "html" 
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/post.html"    postCtx
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= relativizeUrls

    match "drafts/*" $ do
        route   $ setExtension "html" 
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/post.html"    postCtx
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= relativizeUrls

    create ["archive.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let archiveCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Archives"            `mappend`
                    constField "archive" ""                  `mappend`
                    defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls

    create ["tags.html"] $ do
        route idRoute
        compile $ do
            tagCloud <- renderTagCloud 80 300 tags 
            let tagsCtx =
                    constField "tagcloud" tagCloud           `mappend`
                    constField "title" "Tags"                `mappend`
                    constField "tagspage" ""                 `mappend`
                    defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/tags.html"    tagsCtx
                >>= loadAndApplyTemplate "templates/default.html" tagsCtx
                >>= relativizeUrls

    match "index.html" $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let indexCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" ""                    `mappend`
                    constField "home" ""                     `mappend`
                    defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    match "templates/*" $ compile templateCompiler

    tagsRules tags $ \tag pattern -> do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll pattern
            let tagPageCtx =
                    listField "posts" postCtx (return posts)      `mappend`
                    constField "title" ("Filed under: " ++ tag)   `mappend`
                    defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/tag.html"     tagPageCtx
                >>= loadAndApplyTemplate "templates/default.html" tagPageCtx
                >>= relativizeUrls

--------------------------------------------------------------------------------
postCtx :: Context String
postCtx =
    dateField "date" "%e %B %Y"  `mappend`
    constField "post" ""         `mappend`
    field "taglist" (\item -> getPageTags (itemIdentifier item)
                              >>= renderTagListNoCount)
                                 `mappend`
    defaultContext

--------------------------------------------------------------------------------
getPageTags :: Identifier -> Compiler Tags
getPageTags identifier = buildTags (fromList [identifier]) (fromCapture "tags/*.html")

renderTagListNoCount :: Tags -> Compiler (String)
renderTagListNoCount = renderTags makeLink (intercalate ", ")
  where makeLink tag url _ _ _ = renderHtml $ 
                                   H.a ! A.href (toValue url) $ toHtml tag

-- The default implementation of compressCss is String -> String
-- Here we turn it into a bindable function for use in compiler
compressCssBindable :: Item String -> Compiler (Item String)
compressCssBindable item = let cssBody = itemBody item
                            in makeItem $ compressCss cssBody
