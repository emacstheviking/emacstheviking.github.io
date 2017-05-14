--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid (mappend)
import           Hakyll


--------------------------------------------------------------------------------
main :: IO ()
main = hakyll $ do
    -- ---------------------------------------------------------------------------
    -- IMAGE TRANSFER
    -- ---------------------------------------------------------------------------
    match "images/*" $ do
        route   idRoute
        compile copyFileCompiler
 
    -- ---------------------------------------------------------------------------
    -- CSS
    -- ---------------------------------------------------------------------------
    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    -- ---------------------------------------------------------------------------
    -- ABOUT and CONTACT
    -- ---------------------------------------------------------------------------
    match (fromList ["about.markdown", "contact.markdown"]) $ do
        route   $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls

    -- ---------------------------------------------------------------------------
    -- POSTS
    -- ---------------------------------------------------------------------------
    tags <- buildTags "posts/*" (fromCapture "tags/*.html")

    tagsRules tags $ \tag pattern -> do
      let title = "Posts tagged \"" ++ tag ++ "\""
      route idRoute
      compile $ do
        posts <- recentFirst =<< loadAll pattern
        let ctx = constField "title" title
                  `mappend` listField "posts" postCtx (return posts)
                  `mappend` defaultContext
        makeItem ""
          >>= loadAndApplyTemplate "templates/tag.html" ctx
          >>= loadAndApplyTemplate "templates/default.html" ctx
          >>= relativizeUrls

    match "posts/*" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/post.html"    (postCtxWithTags tags)
            >>= loadAndApplyTemplate "templates/default.html" (postCtxWithTags tags)
            >>= relativizeUrls

    -- ---------------------------------------------------------------------------
    -- ARCHIVES
    -- ---------------------------------------------------------------------------
    create ["archive.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let archiveCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Archives"            `mappend`
                    defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls


    -- ---------------------------------------------------------------------------
    -- INDEX/HOME PAGE construction
    -- ---------------------------------------------------------------------------
    match "index.html" $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let indexCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Home"                `mappend`
                    defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    -- ---------------------------------------------------------------------------
    -- TEMPLATES compilation
    -- ---------------------------------------------------------------------------
    match "templates/*" $ compile templateBodyCompiler




--------------------------------------------------------------------------------
-- Custom code for helping to build the site content here...
--------------------------------------------------------------------------------
postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y" `mappend`
    defaultContext

postCtxWithTags :: Tags -> Context String
postCtxWithTags tags = tagsField "tags" tags `mappend` postCtx
