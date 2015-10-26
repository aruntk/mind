class ComputeTallyJob extends Job
  @register()

  run: ->
    motion = @data.motion

    votes = Vote.documents.find('motion._id': motion._id).map (vote, index, cursor) ->
      vote.value

    computedAt = new Date()

    # TODO: Get all users with voting role?
    populationSize = 10 # User.documents.count()

    result = VotingEngine.computeTally votes, populationSize

    documentId = Tally.documents.insert
      createdAt: computedAt
      motion:
        _id: motion._id
      job:
        _id: @_id
      populationSize: populationSize
      votesCount: result.votesCount
      abstainsCount: result.abstainsCount
      inFavorVotesCount: result.inFavorVotesCount
      againstVotesCount: result.againstVotesCount
      confidenceLevel: result.confidenceLevel
      result: result.result

    assert documentId

    tally:
      _id: documentId
