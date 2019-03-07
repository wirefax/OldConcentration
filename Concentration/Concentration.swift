//
//  Concentration.swift
//  Concentration
//
//  Created by Maksym Logvin on 1/16/19.
//  Copyright © 2019 Maksym Logvin. All rights reserved.
//

//MARK: Фреймворк Foundation, а не UIKit, потому что модель всегда UI-независима
import Foundation

//MARK: Расширение протокола коллекции, который соблюдают такие типы как Array, String, CountableRange
//Позволяет выводить элемент коллекции только в том случае, если у коллекции только один элемент, в противном случае - nil
extension Collection {
    var oneAndOnly: Element? {
        return count == 1 ? first: nil
    }
}

class Concentration
{
    //MARK: Массив всех карт в игре, в начале он всегда пустой
    //Сущность Card находится в другом файле модели Card.swift в виде структуры, а не класса
    //Благодаря установке доступа мы можем смотреть на карты и использовать их в игре, но не давать изменять их свойства
    private (set) var cards = [Card]()
    
    //MARK: Переменная которая отслеживает ситуацию при которой только ОДНА карта на столе лежит лицевой стороной, и следующую выбранную карту нужно будет сравнивать с ней на совпадение
    //Тип переменной ОПЦИОНАЛ, потому что в тех ситуациях когда на столе нет карт с лицевой стороной или лежат две открытые карты, значение переменной - NOT SET
    //В любой момент времени можно получить индекс карты с лицевой стороной, который можно сравнить, а если значение NIL, то и делать ничего не нужно
    //Переменная реализована как вычисляемое свойство (computed property), если при просмотре всех карт в GET мы найдет только одну карту лицом вверх - возвращаем ее индекс, иначе - NIL (это значение является дефолтным при декларировании опционала! переменная получает его АВТОМАТИЧЕСКИ)
    //Реализация поиска идекса перевернутой карты через замыкание, основана на методе filter, который проверяет все элементы массива карты на соответствие одному параметру isFaceUp == true, и тот единственный индекс для кого это утверждение верно - присваивает в качестве значения indexOfOneAndOnlyFaceUpCard, в остальных случаях - когда таких карт нет или их больше 1 - возвращает nil
    //В SET мы ищем карту с индексом newValue и переворачиваем ее лицом, укладывая остальные лицом вниз
    //Переменная никогда нигде не запоминается, вместо этого каждый раз, когда ее запрашивают она вычисляется кодом внутри GET
    //А если значение переменной меняется извне, то выполняется код внутри SET (этой части у таких свойств может не быть, но GET всегда есть)
    private var indexOfOneAndOnlyFaceUpCard: Int? {
        get {
            //let faceUpCardIndices = cards.indices.filter {cards[$0].isFaceUp}
            //return faceUpCardIndices.count == 1 ? faceUpCardIndices.first : nil
            return cards.indices.filter{cards[$0].isFaceUp}.oneAndOnly
            /*var foundIndex: Int?
            for index in cards.indices {
                if cards[index].isFaceUp {
                    if foundIndex == nil {
                        foundIndex = index
                    } else {
                        return nil
                    }
                }
            }
            return foundIndex*/
        }
        
        set (newValue) {
            for index in cards.indices {
                cards [index].isFaceUp = (index == newValue)
            }
        }
    }
    
    
    //MARK: Метод выбора карты
    //В качестве передающего аргумента используется индекс карты в массиве cards
    //Первое условие - игнорирование совпавших карт с прозрачной заливкой, на них не обращаем внимание
    //Вся логика игры сосредоточена здесь!!!
    func chooseCard(at index:Int) {
        //Утверждение, в котором содержится информация о причине возможного аварийного завершения при отладке приложения с указанием неверного значения переменной
        //Если все индексы массива cards не содержат переданный аргумент "индекс", то приложение аварийно завершится с пояснительной надписью
        assert(cards.indices.contains(index), "Concentration.chooseCard(at: \(index)): choosen index not in the cards")
        if !cards[index].isMatched {
            if let matchIndex = indexOfOneAndOnlyFaceUpCard, matchIndex != index {
                //check if cards match
                //MARK: Просматриваем все карты и смотрим, найдем ли мы только одну карту, которая лежит лицевой стороной вверх
                if cards[matchIndex] == cards[index] {
                    cards[matchIndex].isMatched = true
                    cards[index].isMatched = true
                }
                cards[index].isFaceUp = true
                //indexOfOneAndOnlyFaceUpCard = nil
            } else {
                //either no cards or cards are face up
                /*for flipdownIndex in cards.indices {
                   cards[flipdownIndex].isFaceUp = false
                }
                cards[index].isFaceUp = true */
                indexOfOneAndOnlyFaceUpCard = index
            }
        }
    }
    /*   if cards[index].isFaceUp {
     cards[index].isFaceUp = false
     } else {
     cards[index].isFaceUp = true
     } */
    
    //MARK: Инициализируем количество пар карт в игре
    //В него передается аргументом количество пар
    //Через цикл в пустой массив cards забиваются парные карты с уникальными ижентификаторами - которые инициализируются в структуре Card
    init (numberOfPairsOfCards: Int) {
        //Утверждение на случай если входяшее количество пар будет меньше или равно 0
        assert (numberOfPairsOfCards > 0, "Concentration.init(\(numberOfPairsOfCards)): you must have a least one pair of cards")
        for _ in 1...numberOfPairsOfCards {
        let card = Card()
       /*   let matchingCard = card
            cards.append(card)
            cards.append(matchingCard)*/
            cards += [card, card]
        }
        // TODO: Shuffle the cards
        var randomCards = [Card]()
        
        for _ in cards.indices {
            let shuffle = cards.remove(at: cards.endIndex.arc4random)
            randomCards.append(shuffle)
        }
        cards = randomCards
    }
}
