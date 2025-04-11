//
//  SupportGroupsView.swift
//  Phil
//
//  Created by Mar Reyes on 10/04/2025.
//


//
//  SupportGroupsView.swift
//  Phil
//
//  Created by Dario on 3/22/25.
//

import SwiftUI

struct SupportGroupsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.primary)
                                .padding(10)
                                .background(Circle().fill(Color.white))
                                .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                        }
                        
                        Text("Support Groups")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Search bar placeholder
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        Text("Search support groups...")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(25)
                    .padding(.horizontal)
                }
                .padding(.vertical, 16)
                .background(Color.white)
                
                // Sample content
                ScrollView {
                    VStack(spacing: 16) {
                        // Some sample groups
                        sampleSupportGroup(
                            name: "Anxiety Support Circle",
                            focusArea: "Anxiety & Panic Disorders",
                            isOnline: false
                        )
                        
                        sampleSupportGroup(
                            name: "Depression Recovery Group",
                            focusArea: "Depression",
                            isOnline: false
                        )
                        
                        sampleSupportGroup(
                            name: "Online Grief Support",
                            focusArea: "Grief & Loss",
                            isOnline: true
                        )
                        
                        sampleSupportGroup(
                            name: "LGBTQ+ Mental Health Alliance",
                            focusArea: "LGBTQ+ Mental Health",
                            isOnline: true
                        )
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    // Sample support group card
    private func sampleSupportGroup(name: String, focusArea: String, isOnline: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(focusArea)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .foregroundColor(.gray)
            }
            
            // Format badge
            HStack(spacing: 8) {
                if isOnline {
                    Label("Online", systemImage: "video.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                } else {
                    Label("In-Person", systemImage: "person.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                Text("Weekly meetings")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Join button
            Button(action: {}) {
                HStack {
                    Image(systemName: "person.badge.plus")
                        .font(.headline)
                    Text("Learn More & Join")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.indigo)
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
    }
}

struct SupportGroupsView_Previews: PreviewProvider {
    static var previews: some View {
        SupportGroupsView()
    }
}