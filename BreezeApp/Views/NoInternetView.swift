//
//  NoInternetView.swift
//  BreezeApp
//
//  Displays when there's no internet connection
//

import SwiftUI

struct NoInternetView: View {
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "wifi.slash")
                    .font(.system(size: 48, weight: .medium))
                    .foregroundColor(.gray)
            }
            
            // Text
            VStack(spacing: 12) {
                Text("No Internet Connection")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Please check your connection and try again")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            // Retry button
            Button(action: onRetry) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Try Again")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 14)
                .background(Color.accentColor)
                .cornerRadius(12)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
    }
}

/// A banner that appears at the top when connection is lost
struct NoInternetBanner: View {
    @Binding var isVisible: Bool
    
    var body: some View {
        if isVisible {
            HStack(spacing: 10) {
                Image(systemName: "wifi.slash")
                    .font(.system(size: 14, weight: .medium))
                
                Text("No internet connection")
                    .font(.system(size: 14, weight: .medium))
                
                Spacer()
                
                Button(action: { isVisible = false }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.red.opacity(0.9))
            .cornerRadius(12)
            .padding(.horizontal, 16)
            .transition(.move(edge: .top).combined(with: .opacity))
            .animation(.spring(), value: isVisible)
        }
    }
}

#Preview {
    NoInternetView(onRetry: {})
}
