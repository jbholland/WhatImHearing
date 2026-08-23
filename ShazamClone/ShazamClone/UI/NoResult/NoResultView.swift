//
//  NoResultView.swift
//  ShazamClone
//
//  Created by Emmanuel Kehinde on 03/07/2021.
//

import SwiftUI

struct NoResultView: View {
    var buttonAction: () -> Void

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
        
            Text("No Result Found")
                .font(.headline)
                .foregroundColor(Color(UIColor.systemGray)).opacity(0.8)

            Button(action: {
                buttonAction()
            }, label: {
                Text("Try Again")
                    .font(.system(size: 14, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .frame(width: 200, height: 48, alignment: .center)
                    .background(
                        RoundedRectangle(cornerRadius: 24).fill(Color(UIColor.systemBlue))
                            .shadow(radius: 1)
                    )
            })
        }
    }
}

struct NoResultView_Previews: PreviewProvider {
    static var previews: some View {
        NoResultView(buttonAction: {})
    }
}
