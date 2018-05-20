//
//  SlackConst.swift
//  HLBeacon
//
//  Created by aoisupersix on 2018/05/20.
//

import Foundation

///Slackの認可コード取得URLです。
///client_id、score、statusをパラメータに付与してGET通信する。
let SLACK_AUTHORIZE_URL = "https://slack.com/oauth/authorize"

///Slackのアクセスコード取得URLです。
///client_id、client_secret、codeをパラメータに付与してGET通信する。
let SLACK_OAUTH_URL = "https://slack.com/api/oauth.access"
