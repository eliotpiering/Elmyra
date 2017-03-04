module Tests exposing (..)

import Test exposing (..)
import Expect
import Fuzz exposing (list, int, tuple, string)
import String
import MyModels exposing (..)
import Array exposing (Array)
import BrowserTreeHelpers


all : Test
all =
    describe "BrowserTreeHelpers"
        [ describe "maybeGetNodeFromLocation"
            --          [] group1
            --          [0]   song1
            --          [1]   group2
            --          [1, 0]     song2
            [ test "returns Nothing if bad index" <|
                \() ->
                    Expect.equal Nothing <|
                        BrowserTreeHelpers.maybeGetNodeFromLocation treeFixture [ -1 ]
            , test "return nothing if bad index in subtree" <|
                \() ->
                    Expect.equal (Nothing) <|
                        BrowserTreeHelpers.maybeGetNodeFromLocation treeFixtureSecondGroup [ 1, -1 ]

            , test "returns GroupNode if index empty" <|
                \() ->
                    Expect.equal (Just treeFixtureFirstGroup) <|
                        BrowserTreeHelpers.maybeGetNodeFromLocation treeFixture []
            , test "returns SongNode if index is 0" <|
                \() ->
                    Expect.equal (Just treeFixtureFirstSong) <|
                        BrowserTreeHelpers.maybeGetNodeFromLocation treeFixture [ 0 ]
            , test "returns secondGroup if index is 1" <|
                \() ->
                    Expect.equal (Just treeFixtureSecondGroup) <|
                        BrowserTreeHelpers.maybeGetNodeFromLocation treeFixture [ 1 ]
            , test "returns secondSong if index is [1, 0]" <|
                \() ->
                    Expect.equal (Just treeFixtureSecondSong) <|
                        BrowserTreeHelpers.maybeGetNodeFromLocation treeFixture [ 1, 0 ]
            ]
        ]



-- describe "Sample Test Suite"
--     [ describe "Unit test examples"
--         [ test "Addition" <|
--             \() ->
--                 Expect.equal (3 + 7) 10
--         , test "String.left" <|
--             \() ->
--                 Expect.equal "a" (String.left 1 "abcdefg")
--         , test "This test should fail - you should remove it" <|
--             \() ->
--                 Expect.fail "Failed as expected!"
--         ]
--     , describe "Fuzz test examples, using randomly generated input"
--         [ fuzz (list int) "Lists always have positive length" <|
--             \aList ->
--                 List.length aList |> Expect.atLeast 0
--         , fuzz (list int) "Sorting a list does not change its length" <|
--             \aList ->
--                 List.sort aList |> List.length |> Expect.equal (List.length aList)
--         , fuzzWith { runs = 1000 } int "List.member will find an integer in a list containing it" <|
--             \i ->
--                 List.member i [ i ] |> Expect.true "If you see this, List.member returned False!"
--         , fuzz2 string string "The length of a string equals the sum of its substrings' lengths" <|
--             \s1 s2 ->
--                 s1 ++ s2 |> String.length |> Expect.equal (String.length s1 + String.length s2)
--         ]
--     ]


treeFixture : ItemTree SongTag GroupTag
treeFixture =
    -- group1
    --     song1
    --     group2
    --       song2
    treeFixtureFirstGroup


treeFixtureFirstGroup =
    GroupNode { name = " group 1", isExpanded = True, location = [], isSelected = False } (Array.fromList [ treeFixtureFirstSong, treeFixtureSecondGroup ])


treeFixtureSecondGroup : ItemTree SongTag GroupTag
treeFixtureSecondGroup =
    GroupNode { name = "group 2", isExpanded = True, location = [ 1 ], isSelected = False } (Array.fromList [ treeFixtureSecondSong ])


treeFixtureFirstSong : ItemTree SongTag GroupTag
treeFixtureFirstSong =
    SongNode { id = 1, artist = "artist", album = "album", title = "song 1", location = [ 0 ], isSelected = False }


treeFixtureSecondSong : ItemTree SongTag GroupTag
treeFixtureSecondSong =
    SongNode { id = 2, artist = "artist", album = "album", title = "song 2", location = [ 1, 0 ], isSelected = False }

-- treeFixtureThirdGroup : ItemTree SongTag GroupTag
-- treeFixtureThirdGroup =
--     GroupNode { name = "group 3", isExpanded = True, location = [ 1 ] } (Array.fromList [ treeFixtureSecondSong ])

-- treeFixtureThirdSong : ItemTree SongTag GroupTag
-- treeFixtureThirdSong =
--     SongNode { id = 3, artist = "artist", album = "album", title = "song 3", location = [ 0, 1 ] }

