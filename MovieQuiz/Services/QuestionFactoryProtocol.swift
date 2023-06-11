//
//  QuestionFactoryProtocol.swift
//  MovieQuiz

import Foundation

protocol QuestionFactoryProtocol {
    func requestNewQuestion() -> QuizQuestion?
}
