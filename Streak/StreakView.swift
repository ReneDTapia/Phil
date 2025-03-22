//
//  StreakView.swift
//  Phil
//
//  Created by Dario on 18/03/25.
//

import SwiftUI

struct StreakView: View {
    // MARK: - Properties
    @Environment(\.presentationMode) var presentationMode
    @State private var currentStreakDays: Int = 8
    @State private var longestStreakDays: Int = 14
    @State private var streakFreezes: Int = 2
    @State private var nextMilestone: Int = 10
    @State private var progressToNextMilestone: Double = 0.8 // 8/10 = 0.8
    @State private var currentMonth: String = "March 2025"
    
    // Calendar grid data
    @State private var daysInMonth: [[DayData]] = []
    
    // Sample data for calendar
    let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    // Colors
    let primaryPurple = Color(red: 0.41, green: 0.41, blue: 0.83) // Purple from the image
    let lightGray = Color(white: 0.9)
    let missedRed = Color(red: 0.9, green: 0.3, blue: 0.3)
    
    // MARK: - Init
    init() {
        generateSampleCalendarData()
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            headerView
            
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Streak Info
                    streakInfoView
                    
                    Divider()
                        .padding(.horizontal, 20)
                    
                    // MARK: - Calendar Section
                    calendarView
                }
                .padding(.bottom, 30)
            }
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.top)
    }
    
    // MARK: - Header View
    private var headerView: some View {
        ZStack {
            primaryPurple
            
            VStack {
                Spacer()
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                    
                    Text("Streak Calendar")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.leading, 8)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
        }
        .frame(height: 110)
    }
    
    // MARK: - Streak Info View
    private var streakInfoView: some View {
        VStack(spacing: 24) {
            // Title and streak freezes
            HStack {
                Text("Your Streak")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
                
                Spacer()
                
                HStack(spacing: 8) {
                    Image(systemName: "shield.fill")
                        .font(.system(size: 20))
                        .foregroundColor(primaryPurple)
                    
                    Text("\(streakFreezes) Streak Freezes")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            // Current and longest streak
            HStack(spacing: 0) {
                VStack(alignment: .center, spacing: 8) {
                    Text("Current Streak")
                        .font(.system(size: 17))
                        .foregroundColor(.gray)
                    
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text("\(currentStreakDays)")
                            .font(.system(size: 42, weight: .bold))
                            .foregroundColor(primaryPurple)
                        
                        Text("days")
                            .font(.system(size: 20))
                            .foregroundColor(.black)
                            .padding(.bottom, 5)
                    }
                }
                .frame(maxWidth: .infinity)
                
                VStack(alignment: .center, spacing: 8) {
                    Text("Longest Streak")
                        .font(.system(size: 17))
                        .foregroundColor(.gray)
                    
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text("\(longestStreakDays)")
                            .font(.system(size: 42, weight: .bold))
                            .foregroundColor(primaryPurple)
                        
                        Text("days")
                            .font(.system(size: 20))
                            .foregroundColor(.black)
                            .padding(.bottom, 5)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 20)
            
            // Next milestone card
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(primaryPurple.opacity(0.1))
                
                VStack(spacing: 12) {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "gift.fill")
                            .font(.system(size: 22))
                            .foregroundColor(primaryPurple)
                            .frame(width: 24, height: 24)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Next milestone: \(nextMilestone)-day streak")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(.black)
                            
                            Text("Reward: 50 gems + 1 streak freeze")
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                    
                    // Progress bar
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .frame(height: 14)
                            .foregroundColor(primaryPurple.opacity(0.2))
                        
                        RoundedRectangle(cornerRadius: 8)
                            .frame(width: UIScreen.main.bounds.width * 0.7 * progressToNextMilestone, height: 14)
                            .foregroundColor(primaryPurple)
                    }
                }
                .padding(18)
            }
            .frame(height: 110)
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Calendar View
    private var calendarView: some View {
        VStack(spacing: 16) {
            // Month header (purple bar)
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(primaryPurple)
                
                HStack {
                    Image(systemName: "calendar")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .padding(.leading, 2)
                    
                    Text(currentMonth)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.leading, 8)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .frame(height: 60)
            .padding(.horizontal, 20)
            
            // Weekday headers
            HStack(spacing: 0) {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            
            // Calendar grid - rebuild completely
            // This is a completely new implementation for the calendar grid
            calendarGridView
        }
    }
    
    // MARK: - Calendar Grid View
    private var calendarGridView: some View {
        VStack(spacing: 20) {
            ForEach(0..<6) { row in
                HStack(spacing: 0) {
                    ForEach(0..<7) { col in
                        let dayNumber = getDayNumber(row: row, col: col)
                        let status = getDayStatus(day: dayNumber)
                        if dayNumber > 0 {
                            ZStack {
                                dayCircle(number: dayNumber, status: status)
                                
                                if dayNumber == 8 {
                                    // Shield icon for streak freeze
                                    Image(systemName: "shield.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.white)
                                        .background(
                                            Circle()
                                                .fill(primaryPurple)
                                                .frame(width: 20, height: 20)
                                        )
                                        .offset(x: 15, y: -12)
                                }
                            }
                        } else {
                            Color.clear
                                .frame(width: 45, height: 45)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.top, 8)
    }
    
    // Helper function to get day number based on row and column
    private func getDayNumber(row: Int, col: Int) -> Int {
        let startDay = 2 // March starts on Sunday (2nd)
        let daysInPreviousRows = row * 7
        let dayInCurrentRow = col
        let calculatedDay = startDay + daysInPreviousRows + dayInCurrentRow
        
        // Return 0 for days before March 2nd or after March 31st
        if calculatedDay < 2 || calculatedDay > 31 {
            return 0
        }
        return calculatedDay
    }
    
    // Helper function to determine day status
    private func getDayStatus(day: Int) -> DayStatus {
        if day >= 2 && day <= 5 || (day >= 11 && day <= 17) {
            return .active
        } else if day == 18 {
            return .missed
        } else if day > 0 {
            return .inactive
        }
        return .inactive
    }
    
    // MARK: - Day Circle View
    private func dayCircle(number: Int, status: DayStatus) -> some View {
        ZStack {
            if number > 0 {
                // Main circle for the day
                Circle()
                    .foregroundColor(status.color(using: primaryPurple, missedColor: missedRed))
                    .frame(width: 45, height: 45)
                
                // Day number
                Text("\(number)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(status.textColor)
            } else {
                // Empty space for days not in this month
                Color.clear
                    .frame(width: 45, height: 45)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Helper Methods
    private func generateSampleCalendarData() {
        // Row 1 (1)
        let row1 = [
            DayData(number: 0, status: .inactive),
            DayData(number: 0, status: .inactive),
            DayData(number: 0, status: .inactive),
            DayData(number: 0, status: .inactive),
            DayData(number: 0, status: .inactive),
            DayData(number: 0, status: .inactive),
            DayData(number: 1, status: .inactive)
        ]
        
        // Row 2 (2-8)
        let row2 = [
            DayData(number: 2, status: .active),
            DayData(number: 3, status: .active),
            DayData(number: 4, status: .active),
            DayData(number: 5, status: .active),
            DayData(number: 6, status: .inactive),
            DayData(number: 7, status: .inactive),
            DayData(number: 8, status: .inactive, hasFreeze: true)
        ]
        
        // Row 3 (9-15)
        let row3 = [
            DayData(number: 9, status: .inactive),
            DayData(number: 10, status: .inactive),
            DayData(number: 11, status: .active),
            DayData(number: 12, status: .active),
            DayData(number: 13, status: .active),
            DayData(number: 14, status: .active),
            DayData(number: 15, status: .active)
        ]
        
        // Row 4 (16-22)
        let row4 = [
            DayData(number: 16, status: .active),
            DayData(number: 17, status: .active),
            DayData(number: 18, status: .missed),
            DayData(number: 19, status: .inactive),
            DayData(number: 20, status: .inactive),
            DayData(number: 21, status: .inactive),
            DayData(number: 22, status: .inactive)
        ]
        
        // Row 5 (23-29)
        let row5 = [
            DayData(number: 23, status: .inactive),
            DayData(number: 24, status: .inactive),
            DayData(number: 25, status: .inactive),
            DayData(number: 26, status: .inactive),
            DayData(number: 27, status: .inactive),
            DayData(number: 28, status: .inactive),
            DayData(number: 29, status: .inactive)
        ]
        
        // Row 6 (30-31)
        let row6 = [
            DayData(number: 30, status: .inactive),
            DayData(number: 31, status: .inactive),
            DayData(number: 0, status: .inactive),
            DayData(number: 0, status: .inactive),
            DayData(number: 0, status: .inactive),
            DayData(number: 0, status: .inactive),
            DayData(number: 0, status: .inactive)
        ]
        
        daysInMonth = [row1, row2, row3, row4, row5, row6]
    }
}

// MARK: - Day Data Model
struct DayData {
    var number: Int
    var status: DayStatus
    var hasFreeze: Bool = false
}

// MARK: - Day Status Enum
enum DayStatus {
    case inactive
    case active
    case missed
    
    func color(using primaryColor: Color, missedColor: Color) -> Color {
        switch self {
        case .inactive:
            return Color.gray.opacity(0.2)
        case .active:
            return primaryColor
        case .missed:
            return missedColor
        }
    }
    
    var textColor: Color {
        switch self {
        case .active, .missed:
            return .white
        case .inactive:
            return .gray
        }
    }
}

// MARK: - Preview
#Preview {
    StreakView()
}

