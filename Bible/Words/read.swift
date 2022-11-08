//
//  read.swift
//  Bible
//
//  Created by 장하림 on 2022/10/27.
//

import Foundation
import UIKit

struct ReadBible: Codable {
    let address: String
    let chapter: String
}

let gospelTitle = ["1. God exists.",
             "2. All the men are sinners.",
             "3. God judges the sin.",
             "4. Men cannot save themselves.",
             "5. Jesus died for you.",
             "6. Jesus is the only Savior for you.",
             "7. You must believe Jesus Christ as yout Savior."]
let gospelTxt = ["Wheter you believe or not, God exists. Yes, He is alive! God created the whole world and everything in this world. God is the ultimate ruler, he governs the world. He is holy and righteous, he will judge the sinful world.",
           "Somebody is good, somebody is evil, but nobody is righteous. Everybody is a sinner before God. All the men in this world are sinners. Sin means all the thoughts and behaviors which are against God's holiness. It is rebellion unto God. If you don't know God, and on't believe hi, don't follow his right way, you are a sinner also.",
           "God is holy and righteous judge. He judges the sin and iniquity. The wages of sin is death. The sinners will be punished in the hell according to their sins.",
           "Men commit sins unto God. So, only God cna forgive those sins. Your virtue, morality, good behavior, religious ceremony cannot save you from sin. You cannot save yourself.",
           "The wages of sin is death. If you want to be forgien, you must pay the wages of sin. Who can pay the sin's penalty for you? No one can. Only Jesus can pay it for you. Jesus Christ is the Son of God. He is righteous, he has no sin. Jesus died on the cross for you. He paid for your sins bleeding his righteous blood.",
           "Jesus died of you. He died for you. He died instead of you. Jeuss Christ redeemed us from all iniquity, transgression, and sins. He can forgive you sins, he can save you, and he can give you the eternal life.",
           "If you want to b e forgiven and be saved, you must believe Jesus Christ as your Savior and receive him in your heart. \nIf you want to get the wonderful salvation that God gives you as the free gift, pray unto God as below.\n\n\"God, I am a sinner before you. But, I want to leave sin and return to you. I believe Jesus Christ who died for me as my personal Savior. COme unto me, and save me from my sin. I pray in Jesus\'name. Amen.\""
]

let gospelWords = ["(Gen. 1:1) In the beginning God created the heaven and the earth.\n(Rom. 11:36) For of him, and through him, and to him, are all things...\n(Eccl. 12:14: For God shall bring every work into judgment, with every secret thing, whether it be good, or whether it be evil.",
             "(Prov. 21:2) Every way of a man is right in his own eyes: but the LORD pondereth the hearts.\n(Rom.3:23) For all have sinned, and come short of the glory of God;\n(Isa. 53:6) All we like sheep have gone astray; we have turned every one to his own way; and the LORD hath laid on him theiniquity of us all.",
             "(Heb. 9:27) And as it is appointed unto men once to die, but after this the judgment:\n(Rom.6:23) For the wages of sin is death; but the gift of God is eternal ife through Jesus Christ our Lord.\n(Rev. 21:8) But the fearful, and unbelieving, and the abominable, and murderers, and whoremongers, and sorcerers, and idolaters, and all liars, shall have their part in the lake which burneth with fire and brimstone: which is the second death.",
             "(Isa. 64:6) But we are all as an unclean thing, and all our righteousnesses are as filthy rags; and we all do fade as a leaf; and our iniquities, like the wind, have taken us away.\n(Eph. 2:8~9) For by grace are ye saved through faith; and that not of yourselves: it is the gift of God: Not of works, lest any man should boast.",
             "(John 3:16) For God so loved the world, that he gave his only begotten Son, that whosoever believeth in him should not perish, but have everlasting life.\n(Rom. 5:8) But God commendeth his love toward us, in that, while we were yet sinners, Christ died for us.",
             "(John 14:6) Jesus saith unto him, I am the way, the truth, and the life: no man cometh unto the Father, but by me.\n(Acts. 4:12) Neither is there salvation in any other: for there is none other name under heaven given among men, whereby we must be saved.",
             "(John 1:12) But as many as received him, to them gave he power to become the sons of God, even to them that believe on his name:\n(Rev. 3:20) Behold, I stand at the door,, and knock: if any man hear my voice, and open the door, I will come in to him, and will sup with him, and hewith me.\n(John 5:24) Verily, verily, I say unto you, He that heareth my word, and believeth on him that sent me, hath everalsting life, and shall not come into condemnation; but is passed from death unto life.\n(John 3:36) He that believeth on the Son hath everlasting life: and he that believeth not the Son shall not see life; but the wrath of God abideth on him."

]

struct WordSave: Codable {
    var address: String
    var chapter: String
}
