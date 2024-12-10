package com.xenditpaymentrn

import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.WritableMap
import com.facebook.react.bridge.WritableNativeMap
import com.xendit.Models.Address
import com.xendit.Models.Authentication
import com.xendit.Models.BillingDetails
import com.xendit.Models.Card
import com.xendit.Models.CardHolderData
import com.xendit.Models.CardInfo
import com.xendit.Models.Customer
import com.xendit.Models.Token

internal fun createCardObj(map: ReadableMap): Card {
    val cardNumber = map.getString("cardNumber")
    val cardExpirationMonth = map.getString("cardExpMonth")
    val cardExpirationYear = map.getString("cardExpYear")
    val cardCVN = map.getString("cardCvn")
    val cardHolder = map.getMap("cardHolder")?.let { createCardHolderObject(it) }

    return Card(cardNumber, cardExpirationMonth, cardExpirationYear, cardCVN, cardHolder)
}

internal fun createCardHolderObject(map: ReadableMap): CardHolderData {
    val firstName = map.getString("firstName")
    val lastName = map.getString("lastName")
    val email = map.getString("email")
    val phoneNumber = map.getString("phoneNumber")

    return CardHolderData(firstName, lastName, email, phoneNumber)
}

internal fun createBillingDetailsObject(map: ReadableMap): BillingDetails =
    BillingDetails().apply {
        givenNames = map.getString("givenNames")
        surname = map.getString("surname")
        email = map.getString("email")
        phoneNumber = map.getString("phoneNumber")
        map.getMap("address")?.let {  addressMap ->
            address = Address().apply {
                country = addressMap.getString("country")
                streetLine1 = addressMap.getString("streetLine1")
                streetLine2 = addressMap.getString("streetLine2")
                city = addressMap.getString("city")
                provinceState = addressMap.getString("provinceState")
                postalCode = addressMap.getString("postalCode")
                category = addressMap.getString("category")
            }
        }
    }

internal fun createCustomerObject(map: ReadableMap): Customer =
    Customer().apply {
        referenceId = map.getString("referenceId")
        givenNames = map.getString("givenNames")
        surname = map.getString("surname")
        email = map.getString("email")
        phoneNumber = map.getString("phoneNumber")
        mobileNumber = map.getString("mobileNumber")
        description = map.getString("description")
        nationality = map.getString("nationality")
        dateOfBirth = map.getString("dateOfBirth")
    }

internal fun Token.toWritableMap() = WritableNativeMap().apply {
    putString("id", id)
    putString("status", status)
    putString("authenticationId", authenticationId)
    putString("maskedCardNumber", maskedCardNumber)
    putBoolean("should3DS", should_3DS)
    putString("failureReason", failureReason)
    putMap("cardInfo", cardInfo.toWritableMap())
}

internal fun CardInfo.toWritableMap() = WritableNativeMap().apply {
    putString("bank", bank)
    putString("country", country)
    putString("type", type)
    putString("brand", brand)
    putString("cardArtUrl", cardArtUrl)
    putString("fingerprint", fingerprint)
}

internal fun Authentication.toWritableMap() = WritableNativeMap().apply {
    putString("id", id)
    putString("cardTokenId", creditCardTokenId)
    putString("authenticationUrl", payerAuthenticationUrl)
    putString("status", status)
    putString("maskedCardNumber", maskedCardNumber)
    putMap("cardInfo", cardInfo.toWritableMap())
    putString("requestPayload", requestPayload)
    putString("authenticationTransactionId", authenticationTransactionId)
    putString("threedsVersion", threedsVersion)
    putString("failureReason", failureReason)
}