//
//  ViewController.swift
//  Concentration
//
//  Created by Maksym Logvin on 1/9/19.
//  Copyright © 2019 Maksym Logvin. All rights reserved.
//

import UIKit

//MARK: Расширение для Integer типа позволяет получить случайное целое число в диапазоне от 0 до указанной переменной
//Если число меньше 0, то получаем рандомное число по модулю
//Если равно 0, то ничего не рандомизируем
extension Int {
    var arc4random: Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -Int(arc4random_uniform(UInt32(abs(self))))
        } else {
            return 0
        }
    }
}

class ViewController: UIViewController {

    //MARK: Переменная-делегат,использующая все свойства и методы сущности Cards (БОЛЬШАЯ ЗЕЛЕНАЯ СТРЕЛКА для разговора Контроллера с Моделью)
    //+1 используется на случай нечетного количества карт для округления парных карт
    //А так было бы достаточно подсчитать количество кнопок и поделить его пополам, чтобы получить количество пар
    //Так как game это свойство ViewController, оно инициализируется перед тем как self становится доступным
    //Использование ленивого ключа lazy не инициализирует это свойство дл первого обращения к нему, и предотвращает замкнутый круг
    //Для lazy переменных использовать наблюдатели свойств НЕЛЬЗЯ
    //Эту переменную можно упростить через ввод вычисляемого свойства "количество пар карт"
    /*lazy var game = Concentration(numberOfPairsOfCards: (cardButtons.count + 1)/2)*/
    //Так как наша модель тесно связана с нашим UI, мы делаем ее доступ не-public
    private lazy var game = Concentration (numberOfPairsOfCards: numberOfPairsCards)
    
    //MARK: Вычисляемое свойство, возвращающее вычисленное значение, каждый раз когда к нему обращаются
    //Так как SET нет, это простое "read only" свойство, поэтому использование GET не обязательно
    var numberOfPairsCards: Int {
                    return (cardButtons.count + 1) / 2
           }
    
    //MARK: Глобальная переменная для updateViewFromModel
    //В нее передается идентификатор текущей темы, чтобы изменить цвет оборотной стороны карты
    var faceDownColor: UIColor = .orange

    
    //MARK: Свойство меняющее тему при нажатии кнопки New Game
    //ДОРАБОТАТЬ!!!!
    var randomIndex: Int = 0 {
        didSet {
            
            switch randomIndex {
            case 0:
                for index in cardButtons.indices {
                    let button = cardButtons[index]
                    button.backgroundColor = .orange
                    }
                faceDownColor = .orange
                view.backgroundColor = UIColor.black
            case 1:
                for index in cardButtons.indices {
                    let button = cardButtons[index]
                    button.backgroundColor = .brown
                }
                faceDownColor = .brown
                view.backgroundColor = UIColor.lightGray
            case 2:
                for index in cardButtons.indices {
                    let button = cardButtons[index]
                    button.backgroundColor = .magenta
                }
                faceDownColor = .magenta
                view.backgroundColor = UIColor.darkGray
            case 3:
                for index in cardButtons.indices {
                    let button = cardButtons[index]
                    button.backgroundColor = .purple
                }
                 faceDownColor = .purple
                view.backgroundColor = UIColor.cyan
            case 4:
                for index in cardButtons.indices {
                    let button = cardButtons[index]
                    button.backgroundColor = .yellow
                }
                faceDownColor = .yellow
                view.backgroundColor = UIColor.green
            case 5:
                for index in cardButtons.indices {
                    let button = cardButtons[index]
                    button.backgroundColor = .blue
                }
                faceDownColor = .blue
                view.backgroundColor = UIColor.red
            default:
                for index in cardButtons.indices {
                    let button = cardButtons[index]
                    button.backgroundColor = .black
                }
                faceDownColor = .black
                view.backgroundColor = UIColor.white
            }
        }
    }
    
    //MARK: Инициализатор счетчика карт
    //didSet - Наблюдатель свойства (Property Observer)
    //При каждом изменении значения счетчика метка получает обновленное значение и выводит его в тексте метке
    //Можно получать значение переменной, но не устанавливать извне, так как это наша внутренняя реализация при переворотах карты
    //Создаем текст с аттрибутами, используя словарь с ключем типа из Objective-C (вынесли в отдельную функцию)
    private (set) var flipCount = 0 {
        didSet {
            updateFlipCountLabel()
        }
    }
    
    //MARK: Функция для счетчика карт, изменяющая аттрибуты текста метки
    //вынесена за пределы didSet для инициализации при запуске приложения
    //если оставить ее внутри переменной-счетчика, аттрибуты текста метки будут меняться только при изменении состояния, т.е. при нажатии на карту
    private func updateFlipCountLabel () {
        let attributes: [NSAttributedString.Key: Any] = [
            .strokeWidth: 5.0,
            .strokeColor: UIColor.orange
        ]
        let attributedString = NSAttributedString (string: traitCollection.verticalSizeClass == .compact ? "Flips: \n\(flipCount)" : "Flips: \n\(flipCount)",
            attributes: attributes) // В зависимости от расположения устройства мы делаем метку двухстрочной либо однострочной
        flipCountLabel.attributedText = attributedString
    }
    
    //Метод вызывающийся каждый раз когда traitCollection и SizeClass изменяются
    //Здесь мы обновляем нашу метку
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateFlipCountLabel()
    }
    
    private var emojiChoises = ["👻", "🎃", "💀", "🤡", "😈", "🤖", "👹", "👺", "👽", "☠️", "👿", "💩", "👾"]
    
    //MARK: Создаем пустой словарь (Dictionary) для эмоджи, в качестве ключа будет использоваться уникальный идентификатор карты identifier
    //Так как словарь эмоджи мы создаем налету, мы не можем позволить вносить в него свои изменения
    private var emoji = [Card:String]()
    
    // MARK: Функция поиска в словаре эмоджи, входящий аргумент типа Card с уникальным идентификатором
    //Поиск в словаре всегда возращает ОПЦИОНАЛ, так как там может и не быть этого значения
    //Эквивалентый код в конце метода - отвечает за вывод эмоджи соответствующего входящему идентификатору
    //Первая половина метода - заполняем пустой словарь рандомными эмоджи из массива эмоджиков emojiChoises
    //Заполнение идет "по требованию" конкретной карты, а не полностью все и скопом
    private func emoji (for card: Card) -> String {
        if emoji[card] == nil, emojiChoises.count > 0 {
            emoji[card] = emojiChoises.remove(at: emojiChoises.count.arc4random)
            }
//        
//        if emoji[card.identifier] != nil {
//        return emoji[card.identifier]!
//        }else{
//        return "?"
//        }
//        - Equality code >>>>>-
        return emoji[card] ?? "?"
    }
    
    @IBOutlet private weak var flipCountLabel: UILabel! {
        didSet {
            updateFlipCountLabel()
        }
    }
    
    @IBAction func newGame(_ sender: UIButton) {
        flipCount = 0
        randomIndex = emojiChoises.endIndex.arc4random
        print (randomIndex)
    }
    
    @IBOutlet private var cardButtons: [UIButton]!
    
    //Для работы с массивом только видимых 20 карт сделана эта переменная которая фильтрует карты по свойству isHidden
    //Если не ввести эту переменную, то при изменении положения экрана будут исчезать карты в том числе и открытые уже
    private var visibleCardButtons: [UIButton]! {
        return cardButtons?.filter {!$0.superview!.isHidden}
    }
    
    
    //MARK: Метод касания карты
    //Счетчик увеличивается на единицу при каждом касании карты
    //Переменной cardNumber присваивается индекс нажатой кнопки
    //Конструкция if..else необходима для нормальной работы с опционалом из свойства индекса Int?
    //Если разместить "!" для принудительного изъятия ассоциированного значения опционала, получим аварийного завершение работы в случае nil
    @IBAction private func touchCard(_ sender: UIButton) {
        flipCount += 1
        if let cardNumber = visibleCardButtons.firstIndex(of: sender) {
                    //flipCard(withEmoji: emojiChoises[cardNumber], on: sender)
            game.chooseCard(at: cardNumber)
            updateViewFromModel()
        } else {
            print("choosen card was not in cardButtons")
        }
// flipCard(withEmoji: "👻", on: sender)
        
    }
    
 /*   @IBAction func touchSecondButton(_ sender: UIButton) {
        flipCount += 1
                flipCard(withEmoji: "🎃", on: sender)
    }*/
    
    /*func flipCard(withEmoji emoji: String, on button: UIButton) {
        if button.currentTitle == emoji {
            button.setTitle("", for: UIControl.State.normal)
            button.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        } else {
            button.setTitle(emoji, for: UIControl.State.normal)
            button.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
    } */
    
    
    //MARK: Метод обновления представления View согласно изменения в Модели, когда game изменится - на экране тоже должны происходить изменения
    //После вызова метода, идет быстрая пробежка через цикл по свойствам всех кнопок-карт
    //Проверяются карты текущей игры, а меняются свойства бекграунд-колора и тайтла КНОПОК
    private func updateViewFromModel() {
        for index in visibleCardButtons.indices {
            let button = visibleCardButtons[index]
            let card = game.cards[index]
            if card.isFaceUp {
                button.setTitle(emoji (for: card), for: UIControl.State.normal)
                button.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                 } else {
                button.setTitle("", for: UIControl.State.normal)
                button.backgroundColor = card.isMatched ? #colorLiteral(red: 0.9698604061, green: 0.2485079455, blue: 0.1116747309, alpha: 0) : faceDownColor
            }
        }
    }
    
    //Каждый раз когда мои сабвью в виде кнопок меняют свое расположение и перерисовываются заново мы должны запускать метод обновления вью из модели
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateViewFromModel()
    }
}

