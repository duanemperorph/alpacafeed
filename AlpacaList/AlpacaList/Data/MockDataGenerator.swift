//
//  MockDataGenerator.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 7/29/23.
//

import Foundation

class MockDataGenerator {
    private static let mockResponses = [
        "Just had the most amazing time at the alpaca farm today! 🦙💕 These fluffy creatures are pure joy! #AlpacaLove #FarmLife",
        "Oh my goodness, your post just brightened my day! Alpacas are the cutest! I've always wanted to visit an alpaca farm. Looks like such a fun and heartwarming experience. 😍 #AlpacaAdventures #FluffyFriends",
        "Meet Coco and Luna, our adorable alpaca duo! They're the best cuddle buddies on the farm. 🥰🦙 #AlpacaCuteness #FurryFriends",
        "Coco and Luna are absolute darlings! 😍 I can't handle all this cuteness in one picture! They look so soft and huggable. Give them a gentle pat for me! 🤗 #AlpacaCuddleParty #AdorableDuo",
        "Spent the weekend learning to spin alpaca wool! 🧶🦙 It's so fascinating and therapeutic. Can't wait to create cozy alpaca yarn projects! #AlpacaWoolCrafts #WeekendHobbies",
        "Wow, your spinning skills are on point! 🙌 The yarn looks incredibly soft and luxurious. Alpaca wool is a dream to work with. Can't wait to see what beautiful creations you come up with! 💖 #AlpacaCrafting #HandmadeHappiness",
        "Just adopted this little alpaca cutie and named her Buttercup! 🌼🦙 She's settling in well and already stealing hearts. #NewestFamilyMember #AlpacaRescue",
        "Buttercup is the perfect name for this little sweetheart! 🌸 You've made such a wonderful choice, and I'm sure she'll be showered with love in her forever home. Thank you for adopting and giving her a loving family! 💕 #AlpacaAdoption #RescueLove",
        "The majestic view during my hike with these alpacas was simply breathtaking! 🏔️🦙 They're fantastic companions for outdoor adventures! #AlpacaHiking #NatureConnection",
        "What a picturesque scene! 😍 Alpacas truly make hiking even more memorable. Their presence against the mountain backdrop is stunning. I can only imagine how wonderful that experience must have been! 🌄 #AlpacaAdventurers #HikingBuddies",
        "Just had the most amazing experience with these adorable alpacas! 😍 They're such gentle and fluffy creatures! #AlpacaLove #AnimalEncounters",
        "I totally agree! Alpacas are simply the cutest! I had a chance to visit an alpaca farm once, and it was the best day ever! ❤️ #AlpacaAdventures",
        "Ah, I'm so jealous! I've always wanted to meet alpacas up close! They look so huggable and sweet! 🥰 #AlpacaDreams",
        "Alpacas are like real-life stuffed animals! 😄 I love their unique personalities and those big, expressive eyes! #AlpacaFriends",
        "Just adopted this little alpaca into our family! 🦙❤️ We're so excited to welcome them home! Any tips for first-time alpaca owners? #NewAlpacaParent #FurryFamily",
        "Congratulations on your new furry family member! They'll bring so much joy to your life! Just make sure to provide them with enough space to roam and access to fresh water and food. Wishing you lots of happy moments together! 🎉 #AlpacaAdoption",
        "Aww, they're absolutely adorable! Alpacas thrive on a diet of hay and grass, and gentle grooming goes a long way in bonding with them. Enjoy the new alpaca parent journey! 🌿🛁 #AlpacaLove",
        "Your alpaca is super cute! When handling them, remember to be calm and patient, as they can be a bit shy at first. They'll warm up to you in no time! Lots of love to your new family member! 💕 #AlpacaTips",
        "Spent the weekend learning about alpacas and their wool. Did you know their fiber is hypoallergenic and comes in so many natural colors? Fascinating creatures! #AlpacaFiber #WeekendLearning",
        "I had no idea about their hypoallergenic wool! That's amazing and eco-friendly! I'm intrigued to learn more now. Thanks for sharing this fun fact! 🌈🐑 #AlpacaWonder",
        "Alpaca wool is not only soft but also incredibly warm! It's perfect for winter clothes. I can't wait to get my hands on some alpaca yarn for knitting! 🧶❄️ #AlpacaCrafts",
        "The variety of natural colors in alpaca fiber is so cool! Nature's palette at its finest! Do you have any alpaca wool products yet? They must be super cozy! 🌟 #AlpacaColors",
        "Just had the most delightful encounter with these fluffy alpacas at the local farm! 😍 They're such gentle and adorable creatures! Have you ever met an alpaca? Share your alpaca stories below! 🦙💕 #AlpacaLove #FarmLife #AdorableAnimals",
        "Oh my goodness, alpacas are the absolute cutest! I visited a farm last summer, and one of them licked my hand. It was the softest thing I've ever felt! 😄 #AlpacaEncounter #MemorableMoments",
        "Alpacas are magical beings! Every time I feel down, I visit an alpaca farm nearby, and their gentle presence just lifts my spirits. It's like therapy with fur! 🌈🦙 #AnimalTherapy #AlpacaMagic",
        "I'm alpaca-obsessed! My friends gave me an alpaca-themed birthday party last month, and it was a dream come true! Can't resist their fluffy charm! 🎉💖 #AlpacaObsession #PartyTime",
        "Spent the day learning about alpacas and their wool! 🧶 Did you know alpaca fiber is hypoallergenic, sustainable, and oh-so-soft? Thinking of starting a knitting project with some alpaca yarn. Any crafters here? 🧶✂️ #AlpacaFiber #KnittingProject #CraftersParadise",
        "Yes, I'm a crafter and I LOVE working with alpaca yarn! It's incredibly warm and lightweight, perfect for cozy scarves and beanies. Can't wait to see what you create! 🧣🧤 #KnittingCommunity #AlpacaCrafts",
        "I had no idea alpaca wool was hypoallergenic! That's great news for those with sensitive skin like me. Thanks for sharing this fascinating information! 🤗 #AlpacaWool #SustainableFashion",
        "Alpaca yarn is a game-changer for any knitting enthusiast! I made a shawl with it last winter, and it's so soft and luxurious. Highly recommend giving it a try! 🧶💕 #AlpacaKnitting #CozyCreations",
        "Met this hilarious alpaca today! They sure know how to strike a pose for the camera! 😂📸 Share your funniest alpaca pictures if you've got 'em! #AlpacaHumor #SayCheese #FunnyFaces",
        "This alpaca definitely wins the 'Best Photobomb' award! 😂🥇 I was trying to take a serene landscape shot, but this cheeky alpaca popped into the frame with a mischievous grin! #PhotobombMaster #AlpacaComedy",
        "I can't stop laughing at this! 😆 During my trip to an alpaca farm, one of them made the goofiest facial expression right as I snapped the picture. It's now my favorite meme! #MemeWorthy #AlpacaMemories",
        "Alpacas are the true supermodels of the animal kingdom! I caught this one giving me the 'blue steel' look straight out of Zoolander! 🕶️📸 #AlpacaFashion #ModelBehavior",
    ]
    
    private static let mockUsers = [
        "AlpacaWoolMaster",
        "PuffyAlpacaCloud",
        "CuriousAlpacaNose",
        "FuzzyFiberLover",
        "AlpacaGrazingChamp",
        "CozyCriaCorner",
        "FluffyAndFabulous",
        "AlpacaAdventureHoof",
        "SnugglyAlpacaHugs",
        "WoolyWanderer",
        "AlpacaBeanieBabe",
        "GracefulGrassMuncher",
        "CuddlyCriaCrew",
        "SoftAndSquishy",
        "AlpacaCharmingSmile",
        "WoolenWhiskers",
        "PlayfulPacaPaws",
        "SpinMeASkein",
        "AlpacaFleeceFancier",
        "LovableLlamaLookalike",
    ]
    
    private static let mockTitles = [
        "Attended an amazing alpaca1 last night! 🎵🎤",
        "Just adopted the cutest rescue alpaca2! 🐶❤️",
        "Enjoying a alpaca3 in the park with friends 🌳🧺",
        "Embarking on a solo backpacking trip through alpaca4! 🌍✈️",
        "Spent the day volunteering at a local soup alpaca5 🥣❤️",
        "Just finished an intense workout at the alpaca! 💪🏋️‍♀️",
        "Tried a new recipe and it turned out delicious! 🍽️😋",
        "Attended a thought-provoking alpaca8 exhibition today 🎨🖼️",
        "Attended an amazing alpaca1 last night! 🎵🎤",
        "Just adopted the cutest rescue alpaca2! 🐶❤️",
        "Enjoying a alpaca3 in the park with friends 🌳🧺",
        "Embarking on a solo backpacking trip through alpaca4! 🌍✈️",
        "Spent the day volunteering at a local soup alpaca5 🥣❤️",
        "Just finished an intense workout at the alpaca! 💪🏋️‍♀️",
        "Tried a new recipe and it turned out delicious! 🍽️😋",
        "Attended a thought-provoking alpaca8 exhibition today 🎨🖼️",
        "Attended an amazing alpaca1 last night! 🎵🎤",
        "Just adopted the cutest rescue alpaca2! 🐶❤️",
        "Enjoying a alpaca3 in the park with friends 🌳🧺",
        "Embarking on a solo backpacking trip through alpaca4! 🌍✈️",
        "Spent the day volunteering at a local soup alpaca5 🥣❤️",
        "Just finished an intense workout at the alpaca! 💪🏋️‍♀️",
        "Tried a new recipe and it turned out delicious! 🍽️😋",
        "Attended a thought-provoking alpaca8 exhibition today 🎨🖼️"
    ]
    
    static func generateData(length: Int = 20, childLength: Int = 5, depth: Int = 3) -> [FeedItem] {
        var items: [FeedItem] = []
        
        for _ in 0..<length {
            let user = mockUsers.randomElement()!
            let title = mockTitles.randomElement()!
            let content = mockResponses.randomElement()!
            let children = generateChildren(length: childLength, depth: depth)
            let item = FeedItem(user: user, title: title, content: content, children: children)
            items.append(item)
        }
        
        return items
    }
    
    static func generateChildren(length: Int, depth: Int) -> [CommentItem] {
        let user = mockUsers.randomElement()!
        let content = mockResponses.randomElement()!
        let children = depth > 0 ? generateChildren(length: length, depth: depth - 1) : []
        return CommentItem(user: user, content: content, children: children)
    }
}
